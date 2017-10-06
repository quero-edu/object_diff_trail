module On
  class Destroy < ActiveRecord::Base
    self.table_name = :on_destroy
    has_object_diff_trail on: [:destroy]
  end
end
