class Authorship < ActiveRecord::Base
  belongs_to :book
  belongs_to :author, class_name: "Person"
  has_object_diff_trail
end
