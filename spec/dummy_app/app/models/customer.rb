class Customer < ActiveRecord::Base
  has_many :orders, dependent: :destroy
  has_object_diff_trail
end
