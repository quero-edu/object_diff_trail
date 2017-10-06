class Editorship < ActiveRecord::Base
  belongs_to :book
  belongs_to :editor
  has_object_diff_trail
end
