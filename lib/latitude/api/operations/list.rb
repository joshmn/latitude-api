# frozen_string_literal: true

module Latitude
  module API
    module Operations
      module List
        def list(params = {}, opts = {})
          params = deep_dup_hash(params)
          path_params = params.delete(:_path_params) || extract_path_params(params, path_param_keys)
          query = build_query(params)
          parsed = execute_request(
            method: :get,
            path: class_url(path_params: path_params),
            query: query,
            opts: opts,
          )
          ListObject.new(
            resource_class: self,
            parsed: parsed,
            request_params: params,
            request_opts: opts,
            path_params: path_params,
          )
        end

        def all(params = {}, opts = {})
          list(params, opts).auto_paging_each.to_a
        end

        private

        def build_query(params)
          params = params.dup
          sort = params.delete(:sort) || params.delete("sort")
          encoded = RequestParams.encode(params)
          encoded_sort = RequestParams.encode_sort(sort)
          [encoded, encoded_sort && !encoded_sort.empty? ? "sort=#{URI.encode_www_form_component(encoded_sort)}" : nil]
            .reject { |s| s.nil? || s.empty? }
            .join("&")
        end

        def deep_dup_hash(hash)
          hash.each_with_object({}) do |(k, v), out|
            out[k] = case v
                     when Hash  then deep_dup_hash(v)
                     when Array then v.dup
                     else v
                     end
          end
        end
      end
    end
  end
end
