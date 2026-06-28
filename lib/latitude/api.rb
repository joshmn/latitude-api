# frozen_string_literal: true

require "json"
require "net/http"
require "openssl"
require "securerandom"
require "time"
require "uri"
require "forwardable"
require "logger"

require "latitude/api/version"
require "latitude/api/errors"
require "latitude/api/util"
require "latitude/api/configuration"
require "latitude/api/request_params"
require "latitude/api/request_options"
require "latitude/api/json_api"
require "latitude/api/api_object"
require "latitude/api/list_object"
require "latitude/api/request_executor"
require "latitude/api/operations/list"
require "latitude/api/operations/create"
require "latitude/api/operations/retrieve"
require "latitude/api/operations/update"
require "latitude/api/operations/delete"
require "latitude/api/operations/action"
require "latitude/api/operations/nested"
require "latitude/api/api_resource"
require "latitude/api/singleton_api_resource"
require "latitude/api/client"

require "latitude/api/resources/server"
require "latitude/api/resources/region"
require "latitude/api/resources/role"
require "latitude/api/resources/event"
require "latitude/api/resources/ip"
require "latitude/api/resources/plan"
require "latitude/api/resources/billing_usage"
require "latitude/api/resources/traffic"
require "latitude/api/resources/user_profile"
require "latitude/api/resources/user_team"
require "latitude/api/resources/project"
require "latitude/api/resources/ssh_key"
require "latitude/api/resources/user_data"
require "latitude/api/resources/tag"
require "latitude/api/resources/team"
require "latitude/api/resources/api_key"
require "latitude/api/resources/elastic_ip"
require "latitude/api/resources/virtual_network"
require "latitude/api/resources/firewall"
require "latitude/api/resources/vpn_session"
require "latitude/api/resources/storage_filesystem"
require "latitude/api/resources/storage_volume"
require "latitude/api/resources/storage_object"
require "latitude/api/resources/virtual_machine"
require "latitude/api/resources/kubernetes_cluster"

module Latitude
  class << self
    extend Forwardable

    def config
      @config ||= API::Configuration.new
    end

    def configure
      yield config
      config
    end

    def reset_config!
      @config = API::Configuration.new
    end

    def_delegators :config,
                   :api_key, :api_key=,
                   :api_base, :api_base=,
                   :api_version, :api_version=,
                   :open_timeout, :open_timeout=,
                   :read_timeout, :read_timeout=,
                   :write_timeout, :write_timeout=,
                   :max_network_retries, :max_network_retries=,
                   :initial_network_retry_delay, :initial_network_retry_delay=,
                   :max_network_retry_delay, :max_network_retry_delay=,
                   :proxy, :proxy=,
                   :verify_ssl_certs, :verify_ssl_certs=,
                   :ca_bundle_path, :ca_bundle_path=,
                   :ca_store, :ca_store=,
                   :logger, :logger=,
                   :log_level, :log_level=,
                   :app_info, :app_info=,
                   :enable_telemetry, :enable_telemetry=,
                   :sensitive_fields, :sensitive_fields=
  end

  module API
    Error                     = Latitude::Error
    ConfigurationError        = Latitude::ConfigurationError
    ConnectionError           = Latitude::ConnectionError
    APIError                  = Latitude::APIError
    BadRequestError           = Latitude::BadRequestError
    AuthenticationError       = Latitude::AuthenticationError
    PermissionError           = Latitude::PermissionError
    NotFoundError             = Latitude::NotFoundError
    ConflictError             = Latitude::ConflictError
    UnprocessableEntityError  = Latitude::UnprocessableEntityError
    RateLimitError            = Latitude::RateLimitError
    ServerError               = Latitude::ServerError
  end

  Server       = API::Resources::Server
  Region       = API::Resources::Region
  Role         = API::Resources::Role
  Event        = API::Resources::Event
  IP           = API::Resources::IP
  Plan         = API::Resources::Plan
  BillingUsage = API::Resources::BillingUsage
  Traffic      = API::Resources::Traffic
  UserProfile  = API::Resources::UserProfile
  UserTeam     = API::Resources::UserTeam
  Project      = API::Resources::Project
  SSHKey       = API::Resources::SSHKey
  UserData     = API::Resources::UserData
  Tag          = API::Resources::Tag
  Team         = API::Resources::Team
  APIKey          = API::Resources::APIKey
  ElasticIP       = API::Resources::ElasticIP
  VirtualNetwork  = API::Resources::VirtualNetwork
  Firewall        = API::Resources::Firewall
  VPNSession      = API::Resources::VPNSession
  VirtualMachine  = API::Resources::VirtualMachine
  KubernetesCluster = API::Resources::KubernetesCluster

  module Storage
    Filesystem = API::Resources::Storage::Filesystem
    Volume     = API::Resources::Storage::Volume
    Object     = API::Resources::Storage::Object
  end

  module User
    Profile = API::Resources::UserProfile
    Team    = API::Resources::UserTeam
  end
end
