class Animal < ActiveRecord::Base
  has_object_diff_trail
  self.inheritance_column = "species"
end
