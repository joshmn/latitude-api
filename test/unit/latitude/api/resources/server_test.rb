# frozen_string_literal: true

require "test_helper"

module Latitude
  module API
    module Resources
      class ServerTest < Minitest::Test
        def test_list_sends_accept_and_auth_headers
          stub_get("/servers", body: json_api_list_response(type: "servers", items: []))
          Latitude::Server.list
          assert_requested(:get, "#{BASE_URL}/servers") do |req|
            assert_equal "Bearer #{TEST_API_KEY}", req.headers["Authorization"]
            assert_equal "application/vnd.api+json", req.headers["Accept"]
          end
        end

        def test_list_encodes_filters_sort_page_and_extra_fields
          WebMock.stub_request(:get, %r{\A#{Regexp.escape(BASE_URL)}/servers})
                 .to_return(status: 200, body: json_api_list_response(type: "servers", items: []),
                            headers: default_response_headers)
          Latitude::Server.list(
            filter: { project: "proj_1", hostname: { prefix: "web" }, tags: %w[tag_1 tag_2] },
            page:   { size: 50, number: 2 },
            extra_fields: { servers: "credentials" },
            sort: "-created_at",
          )
          assert_requested(:get, /#{Regexp.escape(BASE_URL)}\/servers\?/) do |req|
            q = URI.decode_www_form(req.uri.query).to_h
            assert_equal "proj_1", q["filter[project]"]
            assert_equal "web",    q["filter[hostname][prefix]"]
            assert_equal "tag_1,tag_2", q["filter[tags]"]
            assert_equal "50", q["page[size]"]
            assert_equal "2",  q["page[number]"]
            assert_equal "credentials", q["extra_fields[servers]"]
            assert_equal "-created_at", q["sort"]
          end
        end

        def test_create_wraps_body_in_json_api_envelope
          stub_post("/servers", status: 201,
                                body: json_api_response(type: "servers", id: "sv_new",
                                                        attributes: { "hostname" => "web01", "status" => "off" }))
          server = Latitude::Server.create(
            project: "proj_1", plan: "c2-small-x86", site: "ASH",
            operating_system: "ubuntu_22_04_x64_lts", hostname: "web01",
          )
          assert_instance_of Latitude::API::Resources::Server, server
          assert_equal "sv_new", server.id
          assert_equal "web01", server.hostname
          assert_equal "off",   server.status

          assert_requested(:post, "#{BASE_URL}/servers") do |req|
            body = JSON.parse(req.body)
            assert_equal "servers", body["data"]["type"]
            assert_equal "proj_1",  body["data"]["attributes"]["project"]
            assert_equal "web01",   body["data"]["attributes"]["hostname"]
            assert_equal "application/json", req.headers["Content-Type"]
          end
        end

        def test_retrieve
          stub_get("/servers/sv_1",
                   body: json_api_response(type: "servers", id: "sv_1", attributes: { "hostname" => "a" }))
          server = Latitude::Server.retrieve("sv_1")
          assert_equal "sv_1", server.id
          assert_equal "a", server.hostname
        end

        def test_update_wraps_body_with_id
          stub_patch("/servers/sv_1",
                     body: json_api_response(type: "servers", id: "sv_1", attributes: { "hostname" => "renamed" }))
          server = Latitude::Server.update("sv_1", hostname: "renamed")
          assert_equal "renamed", server.hostname

          assert_requested(:patch, "#{BASE_URL}/servers/sv_1") do |req|
            body = JSON.parse(req.body)
            assert_equal "servers", body["data"]["type"]
            assert_equal "sv_1", body["data"]["id"]
            assert_equal "renamed", body["data"]["attributes"]["hostname"]
          end
        end

        def test_instance_save_patches_only_unsaved_attributes
          stub_get("/servers/sv_1",
                   body: json_api_response(type: "servers", id: "sv_1",
                                           attributes: { "hostname" => "old", "price" => 599 }))
          stub_patch("/servers/sv_1",
                     body: json_api_response(type: "servers", id: "sv_1",
                                             attributes: { "hostname" => "new", "price" => 599 }))
          server = Latitude::Server.retrieve("sv_1")
          server.hostname = "new"
          assert server.changed?
          server.save
          refute server.changed?
          assert_requested(:patch, "#{BASE_URL}/servers/sv_1") do |req|
            body = JSON.parse(req.body)
            assert_equal({ "hostname" => "new" }, body["data"]["attributes"])
          end
        end

        def test_delete_class_and_instance
          stub_delete("/servers/sv_1", status: 204)
          assert_equal true, Latitude::Server.delete("sv_1")

          stub_get("/servers/sv_2",
                   body: json_api_response(type: "servers", id: "sv_2", attributes: { "hostname" => "x" }))
          stub_delete("/servers/sv_2", status: 204)
          server = Latitude::Server.retrieve("sv_2")
          server.delete
          assert_requested(:delete, "#{BASE_URL}/servers/sv_2", times: 1)
        end

        def test_power_action_reboot_posts_action_envelope
          stub_post("/servers/sv_1/actions",
                    body: JSON.generate("data" => { "id" => "act_1", "type" => "actions",
                                                    "attributes" => { "status" => "Rebooting device" } }, "meta" => {}))
          Latitude::Server.reboot("sv_1")
          assert_requested(:post, "#{BASE_URL}/servers/sv_1/actions") do |req|
            body = JSON.parse(req.body)
            assert_equal "actions", body["data"]["type"]
            assert_equal "reboot",  body["data"]["attributes"]["action"]
          end
        end

        def test_instance_action_uses_instance_id
          stub_get("/servers/sv_1",
                   body: json_api_response(type: "servers", id: "sv_1", attributes: { "hostname" => "x" }))
          stub_post("/servers/sv_1/lock", body: "{}")
          server = Latitude::Server.retrieve("sv_1")
          server.lock
          assert_requested(:post, "#{BASE_URL}/servers/sv_1/lock", times: 1)
        end

        def test_schedule_deletion_and_unschedule
          stub_post("/servers/sv_1/schedule_deletion", body: "{}")
          Latitude::Server.schedule_deletion("sv_1", at: "2026-05-01T00:00:00Z", reason: "retire")
          assert_requested(:post, "#{BASE_URL}/servers/sv_1/schedule_deletion") do |req|
            body = JSON.parse(req.body)
            assert_equal "2026-05-01T00:00:00Z", body["at"]
            assert_equal "retire", body["reason"]
          end

          stub_delete("/servers/sv_1/schedule_deletion", status: 204)
          Latitude::Server.unschedule_deletion("sv_1")
          assert_requested(:delete, "#{BASE_URL}/servers/sv_1/schedule_deletion", times: 1)
        end

        def test_reinstall_posts_reinstalls_envelope
          stub_post("/servers/sv_1/reinstall", body: "{}")
          Latitude::Server.reinstall("sv_1", operating_system: "ubuntu_22_04_x64_lts", hostname: "web01")
          assert_requested(:post, "#{BASE_URL}/servers/sv_1/reinstall") do |req|
            body = JSON.parse(req.body)
            assert_equal "reinstalls", body["data"]["type"]
            assert_equal "ubuntu_22_04_x64_lts", body["data"]["attributes"]["operating_system"]
            assert_equal "web01", body["data"]["attributes"]["hostname"]
          end
        end

        def test_not_found_raises_typed_error
          stub_get("/servers/sv_bogus", status: 404,
                                        body: json_api_error(status: 404, code: "not_found",
                                                             detail: "Specified Record Not Found"))
          error = assert_raises(NotFoundError) { Latitude::Server.retrieve("sv_bogus") }
          assert_equal 404, error.http_status
          assert_equal "not_found", error.code
          assert_equal "Specified Record Not Found", error.detail
        end

        def test_rate_limit_surfaces_retry_after_from_meta
          stub_get("/servers", status: 429, body: JSON.generate(
            "errors" => [{
              "status" => "429", "code" => "RATE_LIMIT_EXCEEDED", "title" => "Rate Limit Exceeded",
              "detail" => "Too many requests. Please slow down and retry.",
              "meta" => { "retry_after" => 42 },
            }],
          ))
          error = assert_raises(RateLimitError) { Latitude::Server.list }
          assert_equal 429, error.http_status
          assert_equal 42, error.retry_after
        end

        def test_authentication_error_on_401
          stub_get("/servers", status: 401,
                               body: json_api_error(status: 401, code: "unauthorized", detail: "Invalid key"))
          assert_raises(AuthenticationError) { Latitude::Server.list }
        end

        def test_sends_api_version_header_when_configured
          Latitude.api_version = "2023-06-01"
          stub_get("/servers", body: json_api_list_response(type: "servers", items: []))
          Latitude::Server.list
          assert_requested(:get, "#{BASE_URL}/servers") do |req|
            assert_equal "2023-06-01", req.headers["Api-Version"] || req.headers["API-Version"]
          end
        ensure
          Latitude.api_version = nil
        end

        def test_sends_idempotency_key_when_provided
          stub_post("/servers", status: 201,
                                body: json_api_response(type: "servers", id: "sv_1", attributes: { "hostname" => "x" }))
          Latitude::Server.create({ hostname: "x" }, { idempotency_key: "idem-1" })
          assert_requested(:post, "#{BASE_URL}/servers") do |req|
            assert_equal "idem-1", req.headers["Idempotency-Key"]
          end
        end

        def test_per_call_api_key_override
          stub_get("/servers", body: json_api_list_response(type: "servers", items: []))
          Latitude::Server.list({}, api_key: "lat_tenant")
          assert_requested(:get, "#{BASE_URL}/servers") do |req|
            assert_equal "Bearer lat_tenant", req.headers["Authorization"]
          end
        end

        def test_client_object_uses_its_own_api_key
          stub_get("/servers", body: json_api_list_response(type: "servers", items: []))
          client = Latitude::Client.new(api_key: "lat_client")
          client.servers.list
          assert_requested(:get, "#{BASE_URL}/servers") do |req|
            assert_equal "Bearer lat_client", req.headers["Authorization"]
          end
        end

        def test_feature_not_enabled_predicate
          stub_get("/servers", status: 403, body: JSON.generate(
            "errors" => [{ "code" => "FEATURE_NOT_ENABLED", "message" => "not enabled" }],
          ))
          error = assert_raises(PermissionError) { Latitude::Server.list }
          assert error.feature_not_enabled?
        end
      end
    end
  end
end
