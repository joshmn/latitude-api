# frozen_string_literal: true

require "test_helper"

module Latitude
  module API
    module Resources
      class ReadOnlyResourcesTest < Minitest::Test
        def test_region_list_and_retrieve
          stub_get("/regions", body: json_api_list_response(
            type: "regions", items: [{ id: "reg_1", attributes: { "name" => "São Paulo", "slug" => "SAO" } }],
          ))
          list = Latitude::Region.list
          assert_equal "SAO", list.first.slug

          stub_get("/regions/reg_1",
                   body: json_api_response(type: "regions", id: "reg_1", attributes: { "name" => "São Paulo" }))
          region = Latitude::Region.retrieve("reg_1")
          assert_equal "reg_1", region.id
        end

        def test_role_list_and_retrieve
          stub_get("/roles", body: json_api_list_response(
            type: "roles", items: [{ id: "role_1", attributes: { "name" => "owner" } }],
          ))
          assert_equal "owner", Latitude::Role.list.first.name

          stub_get("/roles/role_1",
                   body: json_api_response(type: "roles", id: "role_1", attributes: { "name" => "admin" }))
          assert_equal "admin", Latitude::Role.retrieve("role_1").name
        end

        def test_event_list
          stub_get("/events", body: json_api_list_response(
            type: "events", items: [{ id: "evt_1", attributes: { "action" => "server.created" } }],
          ))
          assert_equal "server.created", Latitude::Event.list.first.action
        end

        def test_event_list_does_not_expose_retrieve
          refute Latitude::Event.respond_to?(:retrieve)
        end

        def test_ip_list_and_retrieve
          stub_get("/ips", body: json_api_list_response(
            type: "ip_addresses", items: [{ id: "ip_1", attributes: { "address" => "1.2.3.4" } }],
          ))
          assert_equal "1.2.3.4", Latitude::IP.list.first.address

          stub_get("/ips/ip_1",
                   body: json_api_response(type: "ip_addresses", id: "ip_1", attributes: { "address" => "5.6.7.8" }))
          assert_equal "5.6.7.8", Latitude::IP.retrieve("ip_1").address
        end

        def test_plan_list_and_retrieve
          stub_get("/plans", body: json_api_list_response(
            type: "plans", items: [{ id: "plan_1", attributes: { "slug" => "c2-small-x86" } }],
          ))
          assert_equal "c2-small-x86", Latitude::Plan.list.first.slug

          stub_get("/plans/plan_1",
                   body: json_api_response(type: "plans", id: "plan_1", attributes: { "slug" => "c2-small-x86" }))
          assert_equal "plan_1", Latitude::Plan.retrieve("plan_1").id
        end

        def test_plan_operating_systems
          stub_get("/plans/operating_systems", body: json_api_list_response(
            type: "operating_system", items: [{ id: "ubuntu_22_04_x64_lts", attributes: { "name" => "Ubuntu 22.04" } }],
          ))
          list = Latitude::Plan::OperatingSystem.list
          assert_equal "Ubuntu 22.04", list.first.name
        end

        def test_plan_bandwidth_list_and_update
          stub_get("/plans/bandwidth", body: json_api_list_response(
            type: "bandwidth_plan", items: [{ id: "bw_1", attributes: { "price" => 100 } }],
          ))
          assert_equal 100, Latitude::Plan::Bandwidth.list.first.price

          stub_post("/plans/bandwidth", status: 200, body: "{}")
          Latitude::Plan::Bandwidth.update_packages(project: "proj_1", packages: [{ "region" => "SAO", "price" => 500 }])
          assert_requested(:post, "#{BASE_URL}/plans/bandwidth") do |req|
            body = JSON.parse(req.body)
            assert_equal "bandwidth_packages", body["data"]["type"]
            assert_equal "proj_1", body["data"]["attributes"]["project"]
          end
        end

        def test_plan_storage_and_virtual_machine_lists
          stub_get("/plans/storage", body: json_api_list_response(
            type: "storage_plans", items: [{ id: "st_1", attributes: { "slug" => "block" } }],
          ))
          assert_equal "block", Latitude::Plan::Storage.list.first.slug

          stub_get("/plans/virtual_machines", body: json_api_list_response(
            type: "virtual_machine_plans", items: [{ id: "vm_1", attributes: { "slug" => "c2.small.vm" } }],
          ))
          assert_equal "c2.small.vm", Latitude::Plan::VirtualMachine.list.first.slug
        end

        def test_billing_usage_retrieve_with_filter
          WebMock.stub_request(:get, %r{\A#{Regexp.escape(BASE_URL)}/billing/usage})
                 .to_return(status: 200, body: json_api_response(type: "billing_usage", id: "",
                                                                 attributes: { "amount" => 42, "threshold" => 10_000 }),
                            headers: default_response_headers)
          usage = Latitude::BillingUsage.retrieve(filter: { project: "proj_1" })
          assert_equal 42, usage.amount

          assert_requested(:get, %r{#{Regexp.escape(BASE_URL)}/billing/usage\?filter%5Bproject%5D=proj_1})
        end

        def test_traffic_retrieve_and_quota
          WebMock.stub_request(:get, %r{\A#{Regexp.escape(BASE_URL)}/traffic(?:\?|\z)})
                 .to_return(status: 200, body: json_api_response(type: "traffic", id: "",
                                                                 attributes: { "total_inbound_gb" => 102 }),
                            headers: default_response_headers)
          t = Latitude::Traffic.retrieve(filter: { date: { gte: "2026-01-01T00:00:00Z" } })
          assert_equal 102, t.total_inbound_gb

          stub_get("/traffic/quota", body: json_api_response(type: "traffic_quota", id: "traffic_quota",
                                                             attributes: { "quota_per_project" => [] }))
          q = Latitude::Traffic.quota
          assert_equal "traffic_quota", q.id
        end

        def test_user_profile_retrieve_and_update
          stub_get("/user/profile", body: json_api_response(
            type: "users", id: "user_1", attributes: { "first_name" => "Jef", "last_name" => "B" },
          ))
          profile = Latitude::User::Profile.retrieve
          assert_equal "Jef", profile.first_name

          stub_patch("/user/profile/user_1", body: json_api_response(
            type: "users", id: "user_1", attributes: { "first_name" => "Jefferey" },
          ))
          updated = Latitude::User::Profile.update("user_1", first_name: "Jefferey")
          assert_equal "Jefferey", updated.first_name
        end

        def test_user_teams_list
          stub_get("/user/teams", body: json_api_list_response(
            type: "teams", items: [{ id: "team_1", attributes: { "name" => "Team A" } }],
          ))
          assert_equal "Team A", Latitude::User::Team.list.first.name
        end
      end
    end
  end
end
