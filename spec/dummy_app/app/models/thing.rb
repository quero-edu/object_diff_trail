class Thing < ActiveRecord::Base
  has_object_diff_trail save_changes: false
end
