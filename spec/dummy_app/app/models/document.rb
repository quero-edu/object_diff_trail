# Demonstrates a "custom versions association name". Instead of the assication
# being named `versions`, it will be named `object_diff_trail_versions`.
class Document < ActiveRecord::Base
  has_object_diff_trail(
    versions: :object_diff_trail_versions,
    on: %i[create update]
  )
end
