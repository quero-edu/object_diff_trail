$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "object_diff_trail/version_number"

Gem::Specification.new do |s|
  s.name = "object_diff_trail"
  s.version = ObjectDiffTrail::VERSION::STRING
  s.platform = Gem::Platform::RUBY
  s.summary = "Track changes to your models."
  s.description = <<-EOS
Track changes to your models, for auditing or versioning. See how a model looked
at any stage in its lifecycle, revert it to any version, or restore it after it
has been destroyed.
  EOS
  s.homepage = "https://github.com/airblade/object_diff_trail"
  s.authors = ["Andy Stewart", "Ben Atkins", "Jared Beck"]
  s.email = "batkinz@gmail.com"
  s.license = "MIT"

  s.files = `git ls-files -z`.split("\x0").select { |f|
    f.match(%r{^(Gemfile|MIT-LICENSE|lib|object_diff_trail.gemspec)/})
  }
  s.executables = []
  s.require_paths = ["lib"]

  s.required_rubygems_version = ">= 1.3.6"
  s.required_ruby_version = ">= 2.2.0"

  # Rails does not follow semver, makes breaking changes in minor versions.
  s.add_dependency "activerecord", [">= 4.2", "< 5.2"]
  s.add_dependency "request_store", "~> 1.1"

  s.add_development_dependency "appraisal", "~> 2.1"
  s.add_development_dependency "rake", "~> 12.0"
  s.add_development_dependency "ffaker", "~> 2.5"

  # Why `railties`? Possibly used by `spec/dummy_app` boot up?
  s.add_development_dependency "railties", [">= 4.2", "< 5.2"]

  s.add_development_dependency "rack-test", "~> 0.6.3"
  s.add_development_dependency "rspec-rails", "~> 3.5"
  s.add_development_dependency "generator_spec", "~> 0.9.3"
  s.add_development_dependency "database_cleaner", "~> 1.2"
  s.add_development_dependency "pry-byebug", "~> 3.4"
  s.add_development_dependency "rubocop", "0.50.0"
  s.add_development_dependency "rubocop-rspec", "~> 1.18.0"
  s.add_development_dependency "timecop", "~> 0.8.0"
  s.add_development_dependency "sqlite3", "~> 1.2"
  s.add_development_dependency "pg", "~> 0.21.0"
  s.add_development_dependency "mysql2", "~> 0.4.2"
end
