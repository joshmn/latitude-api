# frozen_string_literal: true

require "test_helper"

module Latitude
  module API
    module Resources
      class NetworkingResourcesTest < Minitest::Test
        def test_elastic_ip_crud_and_move
          stub_get("/elastic_ips", body: json_api_list_response(
            type: "elastic_ips", items: [{ id: "eip_1", attributes: { "address" => "1.2.3.4" } }],
          ))
          assert_equal "1.2.3.4", Latitude::ElasticIP.list.first.address

          stub_post("/elastic_ips", status: 201,
                                    body: json_api_response(type: "elastic_ips", id: "eip_2",
                                                            attributes: { "address" => "5.6.7.8" }))
          eip = Latitude::ElasticIP.create(project_id: "proj_1", server_id: "sv_1")
          assert_equal "eip_2", eip.id

          stub_patch("/elastic_ips/eip_2",
                     body: json_api_response(type: "elastic_ips", id: "eip_2",
                                             attributes: { "server_id" => "sv_new" }))
          moved = Latitude::ElasticIP.move("eip_2", server_id: "sv_new")
          assert_equal "sv_new", moved.server_id

          assert_requested(:patch, "#{BASE_URL}/elastic_ips/eip_2") do |req|
            body = JSON.parse(req.body)
            assert_equal "elastic_ips", body["data"]["type"]
            assert_equal "sv_new", body["data"]["attributes"]["server_id"]
          end

          stub_delete("/elastic_ips/eip_2", status: 204)
          assert_equal true, Latitude::ElasticIP.delete("eip_2")
        end

        def test_virtual_network_crud
          stub_get("/virtual_networks", body: json_api_list_response(
            type: "virtual_networks", items: [{ id: "vlan_1", attributes: { "vid" => 100 } }],
          ))
          assert_equal 100, Latitude::VirtualNetwork.list.first.vid

          stub_post("/virtual_networks", status: 201,
                                         body: json_api_response(type: "virtual_networks", id: "vlan_2",
                                                                 attributes: { "vid" => 200 }))
          assert_equal "vlan_2", Latitude::VirtualNetwork.create(site: "SAO", project: "proj_1").id

          stub_delete("/virtual_networks/vlan_2", status: 204)
          Latitude::VirtualNetwork.delete("vlan_2")
        end

        def test_virtual_network_assignments
          stub_get("/virtual_networks/assignments", body: json_api_list_response(
            type: "virtual_network_assignment",
            items: [{ id: "asn_1", attributes: { "server_id" => "sv_1" } }],
          ))
          assert_equal "sv_1", Latitude::VirtualNetwork::Assignment.list.first.server_id

          stub_post("/virtual_networks/assignments", status: 201,
                                                     body: json_api_response(type: "virtual_network_assignment",
                                                                             id: "asn_2",
                                                                             attributes: { "vid" => 100 }))
          Latitude::VirtualNetwork::Assignment.create(virtual_network_id: "vlan_1", server_id: "sv_2")
          assert_requested(:post, "#{BASE_URL}/virtual_networks/assignments") do |req|
            body = JSON.parse(req.body)
            assert_equal "virtual_network_assignment", body["data"]["type"]
            assert_equal "vlan_1", body["data"]["attributes"]["virtual_network_id"]
          end

          stub_delete("/virtual_networks/assignments/asn_2", status: 204)
          Latitude::VirtualNetwork::Assignment.delete("asn_2")
        end

        def test_firewall_crud
          stub_get("/firewalls", body: json_api_list_response(
            type: "firewalls", items: [{ id: "firewall_1", attributes: { "name" => "default" } }],
          ))
          assert_equal "default", Latitude::Firewall.list.first.name

          stub_post("/firewalls", status: 201,
                                  body: json_api_response(type: "firewalls", id: "firewall_2",
                                                          attributes: { "name" => "prod" }))
          Latitude::Firewall.create(name: "prod", project: "proj_1", rules: [])
        end

        def test_firewall_assignments_scoped_and_global
          stub_post("/firewalls/firewall_1/assignments", status: 201,
                                                         body: json_api_response(type: "firewall_assignments",
                                                                                 id: "fa_1",
                                                                                 attributes: { "server_id" => "sv_1" }))
          Latitude::Firewall::Assignment.create(firewall_id: "firewall_1", server_id: "sv_1")

          stub_get("/firewalls/firewall_1/assignments", body: json_api_list_response(
            type: "firewall_assignments", items: [{ id: "fa_1", attributes: { "server_id" => "sv_1" } }],
          ))
          assert_equal "sv_1", Latitude::Firewall::Assignment.list(firewall_id: "firewall_1").first.server_id

          stub_get("/firewalls/assignments", body: json_api_list_response(
            type: "firewall_assignments", items: [{ id: "fa_2", attributes: { "server_id" => "sv_2" } }],
          ))
          assert_equal "sv_2", Latitude::Firewall::Assignment.list_all.first.server_id

          stub_delete("/firewalls/firewall_1/assignments/fa_1", status: 204)
          Latitude::Firewall::Assignment.delete("fa_1", firewall_id: "firewall_1")
        end

        def test_vpn_session_crud_and_refresh
          stub_get("/vpn_sessions", body: json_api_list_response(
            type: "vpn_sessions", items: [{ id: "vpn_1", attributes: { "username" => "alice" } }],
          ))
          assert_equal "alice", Latitude::VPNSession.list.first.username

          stub_post("/vpn_sessions", status: 201,
                                     body: json_api_response(type: "vpn_sessions", id: "vpn_2",
                                                             attributes: { "username" => "bob" }))
          Latitude::VPNSession.create

          stub_patch("/vpn_sessions/vpn_2/refresh_password",
                     body: json_api_response(type: "vpn_sessions", id: "vpn_2",
                                             attributes: { "password" => "new_pass" }))
          refreshed = Latitude::VPNSession.refresh_password("vpn_2")
          assert_equal "new_pass", refreshed.password

          stub_delete("/vpn_sessions/vpn_2", status: 204)
          Latitude::VPNSession.delete("vpn_2")
        end
      end
    end
  end
end
