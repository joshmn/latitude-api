# frozen_string_literal: true

require_relative "lib/latitude/api/version"

Gem::Specification.new do |spec|
  spec.name = "latitude-api"
  spec.version = Latitude::API::VERSION
  spec.authors = ["Josh Brody"]
  spec.email = ["git@josh.mn"]

  spec.summary = "Ruby client for the Latitude.sh API"
  spec.description = "A Ruby library for the Latitude.sh REST API. Covers servers, projects, virtual machines, " \
                     "Kubernetes clusters, storage, networking, firewalls, elastic IPs, SSH keys, teams, and " \
                     "more. Includes a client for the on-instance metadata service."
  spec.homepage = "https://github.com/joshmn/latitude-api"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/joshdotmn/latitude-api"
  spec.metadata["changelog_uri"] = "https://github.com/joshdotmn/latitude-api/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/latitude-api"
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ Gemfile .gitignore .github/ postman.json])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "~> 0.22"
  spec.add_dependency "logger", "~> 1.6"
end
