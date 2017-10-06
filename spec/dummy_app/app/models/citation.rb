class Citation < ActiveRecord::Base
  belongs_to :quotation

  has_object_diff_trail
end
