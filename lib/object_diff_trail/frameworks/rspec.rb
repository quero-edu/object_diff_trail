require "rspec/core"
require "rspec/matchers"
require "object_diff_trail/frameworks/rspec/helpers"

RSpec.configure do |config|
  config.include ::ObjectDiffTrail::RSpec::Helpers::InstanceMethods
  config.extend ::ObjectDiffTrail::RSpec::Helpers::ClassMethods

  config.before(:each) do
    ::ObjectDiffTrail.enabled = false
    ::ObjectDiffTrail.enabled_for_controller = true
    ::ObjectDiffTrail.whodunnit = nil
    ::ObjectDiffTrail.controller_info = {} if defined?(::Rails) && defined?(::RSpec::Rails)
  end

  config.before(:each, versioning: true) do
    ::ObjectDiffTrail.enabled = true
  end
end

RSpec::Matchers.define :be_versioned do
  # check to see if the model has `has_object_diff_trail` declared on it
  match { |actual| actual.is_a?(::ObjectDiffTrail::Model::InstanceMethods) }
end

RSpec::Matchers.define :have_a_version_with do |attributes|
  # check if the model has a version with the specified attributes
  match do |actual|
    versions_association = actual.class.versions_association_name
    actual.send(versions_association).where_object(attributes).any?
  end
end

RSpec::Matchers.define :have_a_version_with_changes do |attributes|
  # check if the model has a version changes with the specified attributes
  match do |actual|
    versions_association = actual.class.versions_association_name
    actual.send(versions_association).where_object_changes(attributes).any?
  end
end
