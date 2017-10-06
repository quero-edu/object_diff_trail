class Order < ActiveRecord::Base
  belongs_to :customer
  has_many :line_items
  has_object_diff_trail
end
