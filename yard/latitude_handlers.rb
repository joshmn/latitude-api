# frozen_string_literal: true

require "yard"

# Custom YARD handlers that teach yardoc about this gem's metaprogramming.
#
# Resource classes build most of their public surface at load time:
#
#   action :reboot, path: "actions", type: "actions", attributes: { action: "reboot" }
#   nested_resource :ssh_keys, class_name: "Latitude::API::Resources::Project::SSHKey"
#
# YARD is a static parser and never executes those calls, so without these
# handlers the generated docs would show empty resource classes. Each handler
# registers the class-level and instance-level methods that the DSL defines.
module LatitudeYARD
  module ParamHelpers
    def first_symbol_param
      param = statement.parameters(false).compact.first
      return nil unless param

      param.source.strip.sub(/\A:/, "").delete('"').delete("'")
    end
  end

  # Handles `action :name, ...` inside resource classes.
  class ActionHandler < YARD::Handlers::Ruby::Base
    include ParamHelpers
    handles method_call(:action)
    namespace_only

    process do
      name = first_symbol_param
      next unless name

      written = statement.comments.to_s.strip
      desc = written.empty? ? "Invokes the `#{name}` action on this resource." : written

      instance = register(YARD::CodeObjects::MethodObject.new(namespace, name, :instance))
      instance.parameters = [["params", "{}"], ["opts", "{}"]]
      instance.dynamic = true
      instance.docstring = <<~DOC
        #{desc}

        @param params [Hash] action attributes sent in the request body
        @param opts [Hash] per-request overrides; see {Latitude::API::RequestOptions}
        @return [Object] the parsed API response
      DOC

      singleton = register(YARD::CodeObjects::MethodObject.new(namespace, name, :class))
      singleton.parameters = [["id", nil], ["params", "{}"], ["opts", "{}"]]
      singleton.dynamic = true
      singleton.docstring = <<~DOC
        #{desc}

        @param id [String] the resource id to act on
        @param params [Hash] action attributes sent in the request body
        @param opts [Hash] per-request overrides; see {Latitude::API::RequestOptions}
        @return [Object] the parsed API response
      DOC
    end
  end

  # Handles `nested_resource :name, class_name: "..."` inside resource classes.
  class NestedResourceHandler < YARD::Handlers::Ruby::Base
    include ParamHelpers
    handles method_call(:nested_resource)
    namespace_only

    process do
      name = first_symbol_param
      next unless name

      target = statement.source[/class_name:\s*["']([\w:]+)["']/, 1]
      returns = target ? "{#{target}}" : "the nested resource"

      instance = register(YARD::CodeObjects::MethodObject.new(namespace, name, :instance))
      instance.dynamic = true
      instance.docstring = <<~DOC
        Accessor for the nested `#{name}` collection, scoped to this resource.

        @return [Latitude::API::Operations::Nested::NestedAccessor] accessor for #{returns}
      DOC

      singleton = register(YARD::CodeObjects::MethodObject.new(namespace, name, :class))
      singleton.parameters = [["id", nil]]
      singleton.dynamic = true
      singleton.docstring = <<~DOC
        Accessor for the nested `#{name}` collection of the parent identified by `id`.

        @param id [String] the parent resource id
        @return [Latitude::API::Operations::Nested::NestedAccessor] accessor for #{returns}
      DOC
    end
  end
end
