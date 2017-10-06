require "object_diff_trail/version_association_concern"

module ObjectDiffTrail
  # This is the default ActiveRecord model provided by ObjectDiffTrail. Most simple
  # applications will only use this and its partner, `Version`, but it is
  # possible to sub-class, extend, or even do without this model entirely.
  # See the readme for details.
  class VersionAssociation < ::ActiveRecord::Base
    include ObjectDiffTrail::VersionAssociationConcern
  end
end
