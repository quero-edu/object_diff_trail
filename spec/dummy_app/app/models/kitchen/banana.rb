module Kitchen
  class Banana < ActiveRecord::Base
    has_object_diff_trail class_name: "Kitchen::BananaVersion"
  end
end
