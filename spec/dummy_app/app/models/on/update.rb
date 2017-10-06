module On
  class Update < ActiveRecord::Base
    self.table_name = :on_update
    has_object_diff_trail on: [:update]
  end
end
