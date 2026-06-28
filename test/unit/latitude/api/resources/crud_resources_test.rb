# frozen_string_literal: true

require "test_helper"

module Latitude
  module API
    module Resources
      class CrudResourcesTest < Minitest::Test
        def test_project_crud
          stub_get("/projects", body: json_api_list_response(type: "projects",
                                                             items: [{ id: "proj_1", attributes: { "name" => "x" } }]))
          assert_equal "x", Latitude::Project.list.first.name

          stub_post("/projects", status: 201,
                                 body: json_api_response(type: "projects", id: "proj_2", attributes: { "name" => "y" }))
          p = Latitude::Project.create(name: "y", provisioning_type: "on_demand")
          assert_equal "proj_2", p.id

          stub_patch("/projects/proj_2",
                     body: json_api_response(type: "projects", id: "proj_2", attributes: { "name" => "z" }))
          assert_equal "z", Latitude::Project.update("proj_2", name: "z").name

          stub_delete("/projects/proj_2", status: 204)
          assert_equal true, Latitude::Project.delete("proj_2")
        end

        def test_project_nested_ssh_keys
          stub_get("/projects/proj_1/ssh_keys", body: json_api_list_response(
            type: "ssh_keys", items: [{ id: "ssh_1", attributes: { "name" => "k" } }],
          ))
          list = Latitude::Project::SSHKey.list(project_id: "proj_1")
          assert_equal "k", list.first.name

          stub_post("/projects/proj_1/ssh_keys", status: 201,
                                                 body: json_api_response(type: "ssh_keys", id: "ssh_2",
                                                                         attributes: { "name" => "bastion" }))
          key = Latitude::Project::SSHKey.create(project_id: "proj_1", name: "bastion", public_key: "ssh-rsa AAA")
          assert_equal "ssh_2", key.id
          assert_requested(:post, "#{BASE_URL}/projects/proj_1/ssh_keys") do |req|
            body = JSON.parse(req.body)
            refute body["data"]["attributes"].key?("project_id")
            assert_equal "bastion", body["data"]["attributes"]["name"]
          end
        end

        def test_project_nested_accessor_via_instance
          stub_post("/projects/proj_1/ssh_keys", status: 201,
                                                 body: json_api_response(type: "ssh_keys", id: "ssh_2",
                                                                         attributes: { "name" => "bastion" }))
          project = Latitude::Project.new(
            { "id" => "proj_1", "type" => "projects", "attributes" => { "name" => "p" } },
          )
          project.ssh_keys.create(name: "bastion", public_key: "ssh-rsa AAA")
          assert_requested(:post, "#{BASE_URL}/projects/proj_1/ssh_keys")
        end

        def test_project_nested_user_data
          stub_get("/projects/proj_1/user_data", body: json_api_list_response(
            type: "user_data", items: [{ id: "ud_1", attributes: { "description" => "bootstrap" } }],
          ))
          assert_equal "bootstrap", Latitude::Project::UserData.list(project_id: "proj_1").first.description
        end

        def test_ssh_key_top_level_crud
          stub_get("/ssh_keys", body: json_api_list_response(
            type: "ssh_keys", items: [{ id: "ssh_1", attributes: { "name" => "k1" } }],
          ))
          assert_equal "k1", Latitude::SSHKey.list.first.name

          stub_get("/ssh_keys/ssh_1",
                   body: json_api_response(type: "ssh_keys", id: "ssh_1", attributes: { "name" => "k1" }))
          assert_equal "ssh_1", Latitude::SSHKey.retrieve("ssh_1").id
        end

        def test_user_data_top_level_crud
          stub_get("/user_data", body: json_api_list_response(
            type: "user_data", items: [{ id: "ud_1", attributes: { "description" => "bootstrap" } }],
          ))
          assert_equal "bootstrap", Latitude::UserData.list.first.description

          stub_delete("/user_data/ud_1", status: 204)
          assert_equal true, Latitude::UserData.delete("ud_1")
        end

        def test_tag_crud
          stub_post("/tags", status: 201,
                             body: json_api_response(type: "tags", id: "tag_1",
                                                     attributes: { "name" => "prod", "color" => "#fff" }))
          t = Latitude::Tag.create(name: "prod", color: "#fff")
          assert_equal "tag_1", t.id

          stub_patch("/tags/tag_1",
                     body: json_api_response(type: "tags", id: "tag_1", attributes: { "name" => "production" }))
          assert_equal "production", Latitude::Tag.update("tag_1", name: "production").name
        end

        def test_team_retrieve_and_update_members
          stub_get("/team", body: json_api_response(type: "teams", id: "team_1", attributes: { "name" => "Infra" }))
          assert_equal "Infra", Latitude::Team.retrieve.name

          stub_get("/team/members", body: json_api_list_response(
            type: "users", items: [{ id: "user_1", attributes: { "email" => "a@b.com" } }],
          ))
          assert_equal "a@b.com", Latitude::Team::Member.list.first.email

          stub_post("/team/members", status: 201,
                                     body: json_api_response(type: "memberships", id: "user_2",
                                                             attributes: { "role" => "collaborator" }))
          m = Latitude::Team::Member.create(email: "x@y.com", role: "collaborator")
          assert_equal "user_2", m.id

          assert_requested(:post, "#{BASE_URL}/team/members") do |req|
            body = JSON.parse(req.body)
            assert_equal "teams", body["data"]["type"]
            assert_equal "x@y.com", body["data"]["attributes"]["email"]
          end
        end

        def test_api_key_rotate
          stub_post("/auth/api_keys", status: 201,
                                      body: json_api_response(type: "api_keys", id: "tok_1",
                                                              attributes: { "name" => "App", "token" => "lat_..." }))
          created = Latitude::APIKey.create(name: "App")
          assert_equal "tok_1", created.id

          stub_patch("/auth/api_keys/tok_1",
                     body: json_api_response(type: "api_keys", id: "tok_1",
                                             attributes: { "name" => "App (read-only)", "read_only" => true }))
          updated = Latitude::APIKey.update("tok_1", name: "App (read-only)", read_only: true)
          assert updated.read_only

          WebMock.stub_request(:put, "#{BASE_URL}/auth/api_keys/tok_1")
                 .to_return(status: 200, body: json_api_response(type: "api_keys", id: "tok_1",
                                                                 attributes: { "name" => "App", "token" => "lat_new" }),
                            headers: default_response_headers)
          rotated = Latitude::APIKey.rotate("tok_1", name: "App")
          assert_equal "lat_new", rotated.token

          assert_requested(:put, "#{BASE_URL}/auth/api_keys/tok_1") do |req|
            body = JSON.parse(req.body)
            assert_equal "api_keys", body["data"]["type"]
            assert_equal "tok_1", body["data"]["id"]
          end

          stub_delete("/auth/api_keys/tok_1", status: 204)
          Latitude::APIKey.delete("tok_1")
        end
      end
    end
  end
end
