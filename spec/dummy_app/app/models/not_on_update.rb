# This model does not record versions when updated.
class NotOnUpdate < ActiveRecord::Base
  has_object_diff_trail on: %i[create destroy]
end
