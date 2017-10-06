module On
  class Create < ActiveRecord::Base
    self.table_name = :on_create
    has_object_diff_trail on: [:create]
  end
end
