# frozen_string_literal: true

module Latitude
  module API
    class APIResource
      extend Attributes::ClassMethods
      include Attributes::InstanceMethods

      class << self
        def resource_type(value = nil)
          @resource_type = value if value
          @resource_type || raise(NotImplementedError, "#{name} must declare resource_type")
        end

        def resource_path(value = nil)
          @resource_path = value if value
          @resource_path || raise(NotImplementedError, "#{name} must declare resource_path")
        end

        def id_prefix(value = nil)
          @id_prefix = value if value
          @id_prefix
        end

        def inherited(subclass)
          super
          subclass.instance_variable_set(:@resource_type, @resource_type)
          subclass.instance_variable_set(:@resource_path, @resource_path)
          subclass.instance_variable_set(:@id_prefix, @id_prefix)
        end

        def class_url(path_params: {})
          fill_path(resource_path, path_params)
        end

        def instance_url(id, path_params: {})
          raise ArgumentError, "id is required" if id.nil? || id.to_s.empty?

          "#{class_url(path_params: path_params)}/#{URI.encode_www_form_component(id)}"
        end

        def execute_request(method:, path:, query: nil, body: nil, opts: {}, headers: {})
          options = RequestOptions.wrap(opts)
          effective = options.apply_to(config_source)
          RequestExecutor.new(effective).execute(
            method: method,
            path: path,
            query: query,
            body: body,
            headers: headers,
            idempotency_key: options.idempotency_key,
            extra_headers: options.headers,
          )
        end

        def construct_from(parsed, opts: {}, path_params: {})
          data = parsed.is_a?(Hash) ? parsed["data"] : nil
          raise APIError, "response missing data envelope" unless data.is_a?(Hash)

          new(data, meta: parsed["meta"], path_params: path_params, opts: opts)
        end

        def config_source
          Thread.current[:latitude_api_config] || Latitude.config
        end

        def with_config(config)
          prev = Thread.current[:latitude_api_config]
          Thread.current[:latitude_api_config] = config
          yield
        ensure
          Thread.current[:latitude_api_config] = prev
        end

        def extract_path_params(params, keys)
          extracted = {}
          keys.each do |k|
            v = params.delete(k) || params.delete(k.to_s)
            extracted[k] = v if v
          end
          extracted
        end

        def path_param_keys
          resource_path.scan(/:(\w+)/).flatten.map(&:to_sym)
        end

        private

        def fill_path(template, path_params)
          filled = template.dup
          path_params.each do |k, v|
            token = ":#{k}"
            raise ArgumentError, "path param #{k} not in template #{template}" unless filled.include?(token)

            filled = filled.gsub(token, URI.encode_www_form_component(v.to_s))
          end
          missing = filled.scan(/:(\w+)/).flatten
          raise ArgumentError, "missing path params: #{missing.join(', ')}" unless missing.empty?

          filled
        end
      end

      attr_reader :id, :type, :meta, :path_params, :raw_data

      def initialize(data, meta: nil, path_params: {}, opts: {})
        @raw_data    = data
        @id          = data["id"]
        @type        = data["type"]
        @meta        = data["meta"] || meta || {}
        @path_params = path_params || {}
        @opts        = opts || {}
        @values      = {}
        @unsaved     = []
        Array(data["attributes"]).each do |k, v|
          @values[k.to_s] = wrap_attribute(k, v)
        end
      end

      def attributes
        @values.each_with_object({}) { |(k, v), h| h[k] = unwrap(v) }
      end

      def to_h
        out = {}
        out["id"] = @id if @id
        out["type"] = @type if @type
        out["attributes"] = attributes
        out["meta"] = @meta unless @meta.nil? || @meta.empty?
        out
      end

      alias to_hash to_h

      def as_json(*_)
        to_h
      end

      def ==(other)
        other.is_a?(self.class) && other.id == @id
      end

      alias eql? ==

      def hash
        [@type, @id].hash
      end

      def inspect
        "#<#{self.class.name} id=#{@id.inspect} #{attributes.map { |k, v| "#{k}=#{v.inspect}" }.join(' ')}>"
      end

      def [](key)
        @values[key.to_s]
      end

      def []=(key, value)
        key_s = key.to_s
        @values[key_s] = wrap_attribute(key_s, value)
        @unsaved << key_s unless @unsaved.include?(key_s)
        value
      end

      def write_attribute(name, value)
        self[name] = value
      end

      def unsaved_attributes
        @unsaved.each_with_object({}) { |k, h| h[k] = unwrap(@values[k]) }
      end

      def changed?
        !@unsaved.empty?
      end

      def refresh(opts = {})
        parsed = self.class.execute_request(method: :get, path: resource_url, opts: opts)
        update_from(parsed)
        self
      end

      def save(opts = {})
        return self unless changed?

        payload = JSONAPI.encode(type: @type || self.class.resource_type, id: @id, attributes: unsaved_attributes)
        parsed = self.class.execute_request(method: :patch, path: resource_url, body: payload, opts: opts)
        update_from(parsed)
        @unsaved.clear
        self
      end

      def delete(opts = {})
        self.class.execute_request(method: :delete, path: resource_url, opts: opts)
        self
      end

      alias destroy delete

      def resource_url
        self.class.instance_url(@id, path_params: @path_params)
      end

      def respond_to_missing?(name, include_private = false)
        return true if @values.key?(name.to_s)
        return true if name.to_s.end_with?("=") && !read_only_attribute?(name.to_s.chomp("="))

        super
      end

      def method_missing(name, *args)
        name_s = name.to_s
        if name_s.end_with?("=") && args.size == 1
          attr_name = name_s.chomp("=")
          if read_only_attribute?(attr_name)
            raise NoMethodError, "cannot assign to read-only attribute #{attr_name}"
          end

          return self[attr_name] = args.first
        end

        return @values[name_s] if @values.key?(name_s) && args.empty?

        super
      end

      READ_ONLY_ATTRIBUTES = %w[id type created_at updated_at].freeze

      private

      def read_only_attribute?(name)
        return true if READ_ONLY_ATTRIBUTES.include?(name)

        spec = attribute_spec(name)
        spec ? spec.read_only : false
      end

      def update_from(parsed)
        data = parsed.is_a?(Hash) ? parsed["data"] : nil
        return unless data.is_a?(Hash)

        @raw_data = data
        @id   = data["id"] if data["id"]
        @type = data["type"] if data["type"]
        @meta = data["meta"] if data["meta"]
        @values = {}
        Array(data["attributes"]).each { |k, v| @values[k.to_s] = wrap_attribute(k, v) }
        self
      end

      def unwrap(value)
        case value
        when APIObject then value.to_h
        when Array     then value.map { |v| unwrap(v) }
        else value
        end
      end
    end
  end
end
