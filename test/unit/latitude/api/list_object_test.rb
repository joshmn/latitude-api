# frozen_string_literal: true

require "test_helper"

module Latitude
  module API
    class ListObjectTest < Minitest::Test
      def test_enumerates_data_as_resources
        stub_get("/servers", body: json_api_list_response(
          type: "servers",
          items: [
            { id: "sv_1", attributes: { "hostname" => "a" } },
            { id: "sv_2", attributes: { "hostname" => "b" } },
          ],
        ))
        list = Latitude::Server.list
        assert_equal 2, list.size
        assert_instance_of Latitude::API::Resources::Server, list.first
        assert_equal "a", list.first.hostname
      end

      def test_has_more_when_data_fills_page
        stub_get("/servers", body: json_api_list_response(
          type: "servers",
          items: (1..20).map { |i| { id: "sv_#{i}", attributes: { "hostname" => "h#{i}" } } },
        ))
        list = Latitude::Server.list
        assert list.has_more?
      end

      def test_has_more_false_when_less_than_page_size
        stub_get("/servers", body: json_api_list_response(
          type: "servers", items: [{ id: "sv_1", attributes: { "hostname" => "a" } }],
        ))
        list = Latitude::Server.list
        refute list.has_more?
      end

      def test_auto_paging_walks_until_exhausted
        full_page = (1..20).map { |i| { id: "sv_#{i}", attributes: { "hostname" => "h#{i}" } } }
        last_page = [{ id: "sv_21", attributes: { "hostname" => "h21" } }]

        WebMock.stub_request(:get, "#{BASE_URL}/servers")
               .to_return(status: 200, body: json_api_list_response(type: "servers", items: full_page),
                          headers: default_response_headers)

        WebMock.stub_request(:get, "#{BASE_URL}/servers")
               .with(query: { "page[number]" => "2", "page[size]" => "20" })
               .to_return(status: 200, body: json_api_list_response(type: "servers", items: last_page),
                          headers: default_response_headers)

        ids = []
        Latitude::Server.list.auto_paging_each { |s| ids << s.id }
        assert_equal 21, ids.size
        assert_equal "sv_1", ids.first
        assert_equal "sv_21", ids.last
      end
    end
  end
end
