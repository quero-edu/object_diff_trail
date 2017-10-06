class Paragraph < ActiveRecord::Base
  belongs_to :section

  has_object_diff_trail
end
