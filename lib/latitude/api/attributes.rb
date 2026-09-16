# frozen_string_literal: true

module Latitude
  module API
    module Attributes
      Spec = Struct.new(:name, :type, :read_only, keyword_init: true)

      # Attribute names that collide with core Ruby/internal methods. For these we
      # still record the spec (so the value is wrapped and documented) but skip the
      # generated accessor; read them via #[] instead.
      RESERVED_NAMES = %w[method class send __send__ object_id __id__ hash dup clone
                          freeze frozen? instance_variable_get instance_variable_set
                          respond_to? is_a? kind_of? equal? itself].freeze

      module ClassMethods
        def attribute(name, type = :string, **opts)
          name = name.to_s
          read_only = opts.fetch(:read_only, false)
          attribute_specs[name] = Spec.new(name: name, type: type, read_only: read_only)

          unless RESERVED_NAMES.include?(name)
            define_method(name) { read_attribute(name) }
            define_method("#{name}=") { |value| write_attribute(name, value) } unless read_only
          end

          attribute_specs[name]
        end

        def attribute_specs
          @attribute_specs ||= (superclass.respond_to?(:attribute_specs) ? superclass.attribute_specs : {}).dup
        end
      end

      module InstanceMethods
        def attribute_spec(name)
          self.class.respond_to?(:attribute_specs) ? self.class.attribute_specs[name.to_s] : nil
        end

        def read_attribute(name)
          @values[name.to_s]
        end

        def wrap_attribute(key, value)
          type = attribute_spec(key)&.type

          if type.is_a?(Array)
            klass = type.first
            return Array(value).map { |v| v.is_a?(Hash) ? klass.new(v) : v } if object_class?(klass)
          elsif object_class?(type)
            return value.is_a?(Hash) ? type.new(value) : value
          end

          APIObject.wrap(value)
        end

        private

        def object_class?(type)
          type.is_a?(Class) && type <= APIObject
        end
      end
    end
  end
end
