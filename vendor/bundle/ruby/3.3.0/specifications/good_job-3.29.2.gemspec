# -*- encoding: utf-8 -*-
# stub: good_job 3.29.2 ruby lib

Gem::Specification.new do |s|
  s.name = "good_job".freeze
  s.version = "3.29.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/bensheldon/good_job/issues", "changelog_uri" => "https://github.com/bensheldon/good_job/blob/master/CHANGELOG.md", "documentation_uri" => "https://rubydoc.info/gems/good_job", "homepage_uri" => "https://github.com/bensheldon/good_job", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/bensheldon/good_job" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ben Sheldon".freeze]
  s.bindir = "exe".freeze
  s.date = "2024-05-23"
  s.description = "A multithreaded, Postgres-based ActiveJob backend for Ruby on Rails".freeze
  s.email = ["bensheldon@gmail.com".freeze]
  s.executables = ["good_job".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "CHANGELOG.md".freeze, "LICENSE.txt".freeze]
  s.files = ["CHANGELOG.md".freeze, "LICENSE.txt".freeze, "README.md".freeze, "exe/good_job".freeze]
  s.homepage = "https://github.com/bensheldon/good_job".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--title".freeze, "GoodJob - a multithreaded, Postgres-based ActiveJob backend for Ruby on Rails".freeze, "--main".freeze, "README.md".freeze, "--line-numbers".freeze, "--inline-source".freeze, "--quiet".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.5.9".freeze
  s.summary = "A multithreaded, Postgres-based ActiveJob backend for Ruby on Rails".freeze

  s.installed_by_version = "3.5.9".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activejob>.freeze, [">= 6.0.0".freeze])
  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 6.0.0".freeze])
  s.add_runtime_dependency(%q<concurrent-ruby>.freeze, [">= 1.0.2".freeze])
  s.add_runtime_dependency(%q<fugit>.freeze, [">= 1.1".freeze])
  s.add_runtime_dependency(%q<railties>.freeze, [">= 6.0.0".freeze])
  s.add_runtime_dependency(%q<thor>.freeze, [">= 0.14.1".freeze])
  s.add_development_dependency(%q<capybara>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<kramdown>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<kramdown-parser-gfm>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<puma>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec-rails>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<selenium-webdriver>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<timecop>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<webrick>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<yard>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<yard-activesupport-concern>.freeze, [">= 0".freeze])
end
