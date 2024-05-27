# -*- encoding: utf-8 -*-
# stub: rspec-github 2.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rspec-github".freeze
  s.version = "2.4.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "homepage_uri" => "https://drieam.github.io/rspec-github", "source_code_uri" => "https://github.com/drieam/rspec-github" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Stef Schenkelaars".freeze]
  s.date = "2022-11-03"
  s.description = "Formatter for RSpec to show errors in GitHub action annotations".freeze
  s.email = ["stef.schenkelaars@gmail.com".freeze]
  s.homepage = "https://drieam.github.io/rspec-github".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.5.9".freeze
  s.summary = "Formatter for RSpec to show errors in GitHub action annotations".freeze

  s.installed_by_version = "3.5.9".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rspec-core>.freeze, ["~> 3.0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.12.0".freeze])
  s.add_development_dependency(%q<rubocop-ast>.freeze, ["~> 1.4.0".freeze])
end
