# frozen_string_literal: true

module Latitude
  module API
    class ListObject
      include Enumerable

      attr_reader :data, :meta, :links, :request_params, :resource_class, :request_opts, :path_params

      def initialize(resource_class:, parsed:, request_params: {}, request_opts: {}, path_params: {})
        @resource_class = resource_class
        @meta           = parsed.is_a?(Hash) ? (parsed["meta"] || {}) : {}
        @links          = parsed.is_a?(Hash) ? (parsed["links"] || {}) : {}
        raw_data        = parsed.is_a?(Hash) ? Array(parsed["data"]) : []
        @data           = raw_data.map do |row|
          resource_class.new(row, path_params: path_params, opts: request_opts)
        end
        @request_params = request_params || {}
        @request_opts   = request_opts || {}
        @path_params    = path_params || {}
      end

      def each(&blk)
        @data.each(&blk)
      end

      def size
        @data.size
      end

      alias length size

      def empty?
        @data.empty?
      end

      def [](index)
        @data[index]
      end

      def first
        @data.first
      end

      def last
        @data.last
      end

      def to_a
        @data.dup
      end

      def page_size
        value = page_params["size"] || page_params[:size]
        (value || 20).to_i
      end

      def page_number
        value = page_params["number"] || page_params[:number]
        (value || 1).to_i
      end

      def has_more?
        return !!@links["next"] if @links && @links["next"]
        return page_number < @meta["total_pages"].to_i if @meta && @meta["total_pages"]

        @data.size >= page_size
      end

      def next_page(opts = {})
        return empty_page unless has_more?

        params = deep_dup(@request_params)
        params[:page] ||= {}
        params[:page][:number] = page_number + 1
        params[:page][:size]   = page_size
        fetch(params, opts)
      end

      def previous_page(opts = {})
        return empty_page if page_number <= 1

        params = deep_dup(@request_params)
        params[:page] ||= {}
        params[:page][:number] = page_number - 1
        params[:page][:size]   = page_size
        fetch(params, opts)
      end

      def auto_paging_each(&blk)
        page = self
        loop do
          page.each(&blk)
          break unless page.has_more?

          page = page.next_page
        end
        self
      end

      private

      def page_params
        (@request_params[:page] || @request_params["page"] || {})
      end

      def fetch(params, opts)
        merged_opts = @request_opts.merge(opts || {})
        params = params.merge(_path_params: @path_params)
        @resource_class.list(params, merged_opts)
      end

      def empty_page
        self.class.new(resource_class: @resource_class, parsed: { "data" => [] },
                       request_params: @request_params, request_opts: @request_opts, path_params: @path_params)
      end

      def deep_dup(hash)
        hash.each_with_object({}) do |(k, v), out|
          out[k] = case v
                   when Hash then deep_dup(v)
                   when Array then v.dup
                   else v
                   end
        end
      end
    end
  end
end
