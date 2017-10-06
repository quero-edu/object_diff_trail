class Skipper < ActiveRecord::Base
  has_object_diff_trail ignore: [:created_at], skip: [:another_timestamp]
end
