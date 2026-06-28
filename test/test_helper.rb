# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "minitest/autorun"
require "minitest/reporters"
require "webmock/minitest"

Minitest::Reporters.use!(Minitest::Reporters::ProgressReporter.new)

require "latitude"

module LatitudeTestHelpers
  BASE_URL = "https://api.latitude.sh"
  TEST_API_KEY = "lat_test_key_123"

  def setup
    super
    Latitude.reset_config!
    Latitude.api_key = TEST_API_KEY
    Latitude.api_base = BASE_URL
  end

  def fixture(path)
    File.read(File.expand_path("support/fixtures/#{path}", __dir__))
  end

  def stub_get(path, status: 200, body: "", headers: {})
    WebMock.stub_request(:get, "#{BASE_URL}#{path}")
           .to_return(status: status, body: body, headers: default_response_headers.merge(headers))
  end

  def stub_post(path, status: 201, body: "", headers: {})
    WebMock.stub_request(:post, "#{BASE_URL}#{path}")
           .to_return(status: status, body: body, headers: default_response_headers.merge(headers))
  end

  def stub_patch(path, status: 200, body: "", headers: {})
    WebMock.stub_request(:patch, "#{BASE_URL}#{path}")
           .to_return(status: status, body: body, headers: default_response_headers.merge(headers))
  end

  def stub_delete(path, status: 204, body: "", headers: {})
    WebMock.stub_request(:delete, "#{BASE_URL}#{path}")
           .to_return(status: status, body: body, headers: default_response_headers.merge(headers))
  end

  def default_response_headers
    { "Content-Type" => "application/vnd.api+json" }
  end

  def json_api_response(type:, id:, attributes: {}, meta: {})
    JSON.generate({
      "data" => { "id" => id, "type" => type, "attributes" => attributes },
      "meta" => meta,
    })
  end

  def json_api_list_response(type:, items:, meta: {}, links: {})
    JSON.generate({
      "data"  => items.map { |i| { "id" => i[:id], "type" => type, "attributes" => i[:attributes] || {} } },
      "meta"  => meta,
      "links" => links,
    })
  end

  def json_api_error(status:, code: "error", title: "Error", detail: "Bad", meta: {})
    JSON.generate("errors" => [
      { "status" => status.to_s, "code" => code, "title" => title, "detail" => detail, "meta" => meta },
    ])
  end
end

class Minitest::Test
  include LatitudeTestHelpers
end
