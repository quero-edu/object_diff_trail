require "active_support/concern"

module ObjectDiffTrail
  # Functionality for `ObjectDiffTrail::VersionAssociation`. Exists in a module
  # for the same reasons outlined in version_concern.rb.
  module VersionAssociationConcern
    extend ::ActiveSupport::Concern

    included do
      belongs_to :version
    end
  end
end
