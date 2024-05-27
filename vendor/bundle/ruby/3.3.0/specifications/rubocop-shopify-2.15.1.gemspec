# -*- encoding: utf-8 -*-
# stub: rubocop-shopify 2.15.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rubocop-shopify".freeze
  s.version = "2.15.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "source_code_uri" => "https://github.com/Shopify/ruby-style-guide/tree/v2.15.1" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Shopify Engineering".freeze]
  s.date = "2024-02-15"
  s.description = "Gem containing the rubocop.yml config that corresponds to the implementation of the Shopify's style guide for Ruby.".freeze
  s.email = "gems@shopify.com".freeze
  s.homepage = "https://shopify.github.io/ruby-style-guide/".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.5.9".freeze
  s.summary = "Shopify's style guide for Ruby.".freeze

  s.installed_by_version = "3.5.9".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rubocop>.freeze, ["~> 1.51".freeze])
end
