class Gadget < ActiveRecord::Base
  has_object_diff_trail ignore: :brand
end
