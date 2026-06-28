# frozen_string_literal: true

require "test_helper"

module Latitude
  module API
    module Resources
      class StorageComputeResourcesTest < Minitest::Test
        def test_storage_filesystem
          stub_post("/storage/filesystems", status: 201,
                                            body: json_api_response(type: "filesystems", id: "fs_1",
                                                                    attributes: { "name" => "data" }))
          Latitude::Storage::Filesystem.create(name: "data", size_in_gb: 100, project: "proj_1", site: "SAO")

          stub_get("/storage/filesystems", body: json_api_list_response(
            type: "filesystems", items: [{ id: "fs_1", attributes: { "name" => "data" } }],
          ))
          assert_equal "data", Latitude::Storage::Filesystem.list.first.name

          stub_patch("/storage/filesystems/fs_1",
                     body: json_api_response(type: "filesystems", id: "fs_1",
                                             attributes: { "name" => "data-2" }))
          Latitude::Storage::Filesystem.update("fs_1", name: "data-2")

          stub_delete("/storage/filesystems/fs_1", status: 204)
          Latitude::Storage::Filesystem.delete("fs_1")
        end

        def test_storage_volume_with_mount
          stub_post("/storage/volumes", status: 201,
                                        body: json_api_response(type: "volumes", id: "vol_1",
                                                                attributes: { "name" => "data" }))
          Latitude::Storage::Volume.create(name: "data", size_in_gb: 1500, project: "proj_1")

          stub_get("/storage/volumes/vol_1",
                   body: json_api_response(type: "volumes", id: "vol_1", attributes: { "name" => "data" }))
          assert_equal "vol_1", Latitude::Storage::Volume.retrieve("vol_1").id

          stub_post("/storage/volumes/vol_1/mount", body: "{}")
          Latitude::Storage::Volume.mount("vol_1", server_id: "sv_1")
          assert_requested(:post, "#{BASE_URL}/storage/volumes/vol_1/mount") do |req|
            body = JSON.parse(req.body)
            assert_equal "volumes", body["data"]["type"]
            assert_equal "sv_1", body["data"]["attributes"]["server_id"]
          end

          stub_delete("/storage/volumes/vol_1", status: 204)
          Latitude::Storage::Volume.delete("vol_1")
        end

        def test_storage_object
          stub_post("/storage/objects", status: 201,
                                        body: json_api_response(type: "object_storages", id: "obj_1",
                                                                attributes: { "name" => "bucket" }))
          Latitude::Storage::Object.create(name: "bucket", region: "SAO")
          assert_requested(:post, "#{BASE_URL}/storage/objects") do |req|
            body = JSON.parse(req.body)
            assert_equal "objects", body["data"]["type"]
          end

          stub_get("/storage/objects", body: json_api_list_response(
            type: "object_storages", items: [{ id: "obj_1", attributes: { "name" => "bucket" } }],
          ))
          assert_equal "bucket", Latitude::Storage::Object.list.first.name
        end

        def test_virtual_machine_crud_and_actions
          stub_post("/virtual_machines", status: 201,
                                         body: json_api_response(type: "virtual_machines", id: "vm_1",
                                                                 attributes: { "hostname" => "vm01" }))
          Latitude::VirtualMachine.create(project: "proj_1", plan: "vm.small", operating_system: "ubuntu_22_04_x64_lts",
                                          hostname: "vm01", region: "SAO")

          stub_post("/virtual_machines/vm_1/actions", body: "{}")
          Latitude::VirtualMachine.reboot("vm_1")
          assert_requested(:post, "#{BASE_URL}/virtual_machines/vm_1/actions") do |req|
            body = JSON.parse(req.body)
            assert_equal "reboot", body["data"]["attributes"]["action"]
          end

          stub_delete("/virtual_machines/vm_1", status: 204)
          Latitude::VirtualMachine.delete("vm_1")
        end

        def test_kubernetes_cluster_crud_and_kubeconfig
          stub_post("/kubernetes_clusters", status: 201,
                                            body: json_api_response(type: "kubernetes_clusters", id: "kc_1",
                                                                    attributes: { "name" => "prod" }))
          Latitude::KubernetesCluster.create(name: "prod", region: "SAO", version: "1.30")

          stub_get("/kubernetes_clusters/kc_1/kubeconfig",
                   body: JSON.generate("data" => { "id" => "kc_1", "type" => "kubernetes_cluster_kubeconfigs",
                                                   "attributes" => { "kubeconfig" => "apiVersion: v1\n" } }))
          kc = Latitude::KubernetesCluster.kubeconfig("kc_1")
          assert_equal "apiVersion: v1\n", kc["data"]["attributes"]["kubeconfig"]

          stub_get("/kubernetes_clusters/available_versions",
                   body: JSON.generate("data" => [{ "id" => "1.30", "type" => "versions" }]))
          versions = Latitude::KubernetesCluster.available_versions
          assert_equal "1.30", versions["data"].first["id"]

          stub_delete("/kubernetes_clusters/kc_1", status: 204)
          Latitude::KubernetesCluster.delete("kc_1")
        end
      end
    end
  end
end
