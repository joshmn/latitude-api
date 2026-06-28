# frozen_string_literal: true

require "httparty"

require "latitude/metadata/errors"
require "latitude/metadata/session"

module Latitude
  module Metadata
    DEFAULT_TTL_SECONDS = 3600
    PATHS = %w[
      instance_id hostname local_ipv4 public_ipv4 public_ipv6 region plan
      operating_system userdata tags network storage ssh_keys vendor
    ].freeze

    module_function

    def all(session: default_session)
      session.all
    end

    PATHS.each do |p|
      define_singleton_method(p) { default_session.fetch(p) }
    end

    def fetch(path, session: default_session)
      session.fetch(path)
    end

    def refresh!
      default_session.refresh_token!
      self
    end

    def reset!
      @default_session = nil
    end

    def default_session
      @default_session ||= Session.new
    end
  end
end
