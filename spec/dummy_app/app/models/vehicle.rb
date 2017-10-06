class Vehicle < ActiveRecord::Base
  # This STI parent class specifically does not call `has_object_diff_trail`.
  # Of its sub-classes, only `Car` is versioned.
end
