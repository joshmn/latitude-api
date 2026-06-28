# frozen_string_literal: true

module Latitude
  class Client
    RESOURCE_ACCESSORS = {
      servers:              "Latitude::API::Resources::Server",
      regions:              "Latitude::API::Resources::Region",
      roles:                "Latitude::API::Resources::Role",
      events:               "Latitude::API::Resources::Event",
      ips:                  "Latitude::API::Resources::IP",
      plans:                "Latitude::API::Resources::Plan",
      billing_usage:        "Latitude::API::Resources::BillingUsage",
      traffic:              "Latitude::API::Resources::Traffic",
      user_profile:         "Latitude::API::Resources::UserProfile",
      user_teams:           "Latitude::API::Resources::UserTeam",
      projects:             "Latitude::API::Resources::Project",
      ssh_keys:             "Latitude::API::Resources::SSHKey",
      user_data:            "Latitude::API::Resources::UserData",
      tags:                 "Latitude::API::Resources::Tag",
      team:                 "Latitude::API::Resources::Team",
      api_keys:             "Latitude::API::Resources::APIKey",
      elastic_ips:          "Latitude::API::Resources::ElasticIP",
      virtual_networks:     "Latitude::API::Resources::VirtualNetwork",
      firewalls:            "Latitude::API::Resources::Firewall",
      vpn_sessions:         "Latitude::API::Resources::VPNSession",
      storage_filesystems:  "Latitude::API::Resources::Storage::Filesystem",
      storage_volumes:      "Latitude::API::Resources::Storage::Volume",
      storage_objects:      "Latitude::API::Resources::Storage::Object",
      virtual_machines:     "Latitude::API::Resources::VirtualMachine",
      kubernetes_clusters:  "Latitude::API::Resources::KubernetesCluster",
    }.freeze

    attr_reader :config

    def initialize(**overrides)
      @config = Latitude.config.dup_with(**overrides)
      @accessors = {}
    end

    def configure
      yield @config
      @config
    end

    def with_config(&blk)
      Latitude::API::APIResource.with_config(@config, &blk)
    end

    RESOURCE_ACCESSORS.each do |name, class_name|
      define_method(name) do
        @accessors[name] ||= ResourceFacade.new(class_name: class_name, config: @config)
      end
    end

    class ResourceFacade
      def initialize(class_name:, config:)
        @class_name = class_name
        @config = config
      end

      def resource_class
        @resource_class ||= ::Object.const_get(@class_name)
      end

      def method_missing(name, *args, **kwargs, &blk)
        if resource_class.respond_to?(name)
          Latitude::API::APIResource.with_config(@config) do
            resource_class.public_send(name, *args, **kwargs, &blk)
          end
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        resource_class.respond_to?(name) || super
      end
    end
  end
end
