# frozen_string_literal: true

require "test_helper"

module Latitude
  class ClientTest < Minitest::Test
    def test_client_exposes_every_registered_resource
      client = Latitude::Client.new(api_key: "lat_client")
      Latitude::Client::RESOURCE_ACCESSORS.each_key do |name|
        assert client.respond_to?(name), "client missing accessor: #{name}"
      end
    end

    def test_client_forwards_api_key_on_list_calls
      stub_get("/projects", body: json_api_list_response(type: "projects", items: []))
      Latitude::Client.new(api_key: "lat_tenant_A").projects.list
      assert_requested(:get, "#{BASE_URL}/projects") do |req|
        assert_equal "Bearer lat_tenant_A", req.headers["Authorization"]
      end
    end

    def test_client_retrieve_singleton_resource
      stub_get("/team", body: json_api_response(type: "teams", id: "team_1", attributes: { "name" => "Infra" }))
      team = Latitude::Client.new(api_key: "lat_X").team.retrieve
      assert_equal "Infra", team.name
    end

    def test_client_forwards_custom_method
      stub_post("/servers/sv_1/lock", body: "{}")
      client = Latitude::Client.new(api_key: "lat_Y")
      client.servers.lock("sv_1")
      assert_requested(:post, "#{BASE_URL}/servers/sv_1/lock") do |req|
        assert_equal "Bearer lat_Y", req.headers["Authorization"]
      end
    end
  end
end
