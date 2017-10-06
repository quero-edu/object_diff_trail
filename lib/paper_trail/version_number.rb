module ObjectDiffTrail
  # The version number of the object_diff_trail gem. Not to be confused with
  # `ObjectDiffTrail::Version`. Ruby constants are case-sensitive, apparently,
  # and they are two different modules! It would be nice to remove `VERSION`,
  # because of this confusion, but it's not worth the breaking change.
  # People are encouraged to use `ObjectDiffTrail.gem_version` instead.
  module VERSION
    MAJOR = 8
    MINOR = 0
    TINY = 0
    PRE = nil

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join(".").freeze

    def self.to_s
      STRING
    end
  end
end
