class Post < ActiveRecord::Base
  has_object_diff_trail class_name: "PostVersion"
end
