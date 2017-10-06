class Boolit < ActiveRecord::Base
  default_scope { where(scoped: true) }
  has_object_diff_trail
end
