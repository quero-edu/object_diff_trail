class Truck < Vehicle
  # This STI child class specifically does not call `has_object_diff_trail`.
  # Of the sub-classes of `Vehicle`, only `Car` is versioned.
end
