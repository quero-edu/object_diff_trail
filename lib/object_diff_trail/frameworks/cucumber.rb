# before hook for Cucumber
Before do
  ObjectDiffTrail.enabled = false
  ObjectDiffTrail.enabled_for_controller = true
  ObjectDiffTrail.whodunnit = nil
  ObjectDiffTrail.controller_info = {} if defined? Rails
end

module ObjectDiffTrail
  module Cucumber
    # Helper method for enabling PT in Cucumber features.
    module Extensions
      # :call-seq:
      # with_versioning
      #
      # enable versioning for specific blocks

      def with_versioning
        was_enabled = ::ObjectDiffTrail.enabled?
        ::ObjectDiffTrail.enabled = true
        begin
          yield
        ensure
          ::ObjectDiffTrail.enabled = was_enabled
        end
      end
    end
  end
end

World ObjectDiffTrail::Cucumber::Extensions
