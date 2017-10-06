module On
  class EmptyArray < ActiveRecord::Base
    self.table_name = :on_empty_array
    has_object_diff_trail on: []
  end
end
