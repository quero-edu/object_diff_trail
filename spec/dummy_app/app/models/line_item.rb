class LineItem < ActiveRecord::Base
  belongs_to :order, dependent: :destroy
  has_object_diff_trail
end
