module ObjectDiffTrail
  module Rails
    # Extensions to rails controllers. Provides convenient ways to pass certain
    # information to the model layer, with `controller_info` and `whodunnit`.
    # Also includes a convenient on/off switch, `enabled_for_controller`.
    module Controller
      def self.included(controller)
        controller.before_action(
          :set_object_diff_trail_enabled_for_controller,
          :set_object_diff_trail_controller_info
        )
      end

      protected

      # Returns the user who is responsible for any changes that occur.
      # By default this calls `current_user` and returns the result.
      #
      # Override this method in your controller to call a different
      # method, e.g. `current_person`, or anything you like.
      def user_for_object_diff_trail
        return unless defined?(current_user)
        ActiveSupport::VERSION::MAJOR >= 4 ? current_user.try!(:id) : current_user.try(:id)
      rescue NoMethodError
        current_user
      end

      # Returns any information about the controller or request that you
      # want ObjectDiffTrail to store alongside any changes that occur.  By
      # default this returns an empty hash.
      #
      # Override this method in your controller to return a hash of any
      # information you need.  The hash's keys must correspond to columns
      # in your `versions` table, so don't forget to add any new columns
      # you need.
      #
      # For example:
      #
      #     {:ip => request.remote_ip, :user_agent => request.user_agent}
      #
      # The columns `ip` and `user_agent` must exist in your `versions` # table.
      #
      # Use the `:meta` option to
      # `ObjectDiffTrail::Model::ClassMethods.has_object_diff_trail` to store any extra
      # model-level data you need.
      def info_for_object_diff_trail
        {}
      end

      # Returns `true` (default) or `false` depending on whether ObjectDiffTrail
      # should be active for the current request.
      #
      # Override this method in your controller to specify when ObjectDiffTrail
      # should be off.
      def object_diff_trail_enabled_for_controller
        ::ObjectDiffTrail.enabled?
      end

      private

      # Tells ObjectDiffTrail whether versions should be saved in the current
      # request.
      def set_object_diff_trail_enabled_for_controller
        ::ObjectDiffTrail.enabled_for_controller = object_diff_trail_enabled_for_controller
      end

      # Tells ObjectDiffTrail who is responsible for any changes that occur.
      def set_object_diff_trail_whodunnit
        @set_object_diff_trail_whodunnit_called = true
        ::ObjectDiffTrail.whodunnit = user_for_object_diff_trail if ::ObjectDiffTrail.enabled_for_controller?
      end

      # Tells ObjectDiffTrail any information from the controller you want to store
      # alongside any changes that occur.
      def set_object_diff_trail_controller_info
        ::ObjectDiffTrail.controller_info = info_for_object_diff_trail if ::ObjectDiffTrail.enabled_for_controller?
      end

      # We have removed this warning. We no longer add it as a callback.
      # However, some people use `skip_after_action :warn_about_not_setting_whodunnit`,
      # so removing this method would be a breaking change. We can remove it
      # in the next major version.
      def warn_about_not_setting_whodunnit
        ::ActiveSupport::Deprecation.warn(
          "warn_about_not_setting_whodunnit is a no-op and is deprecated."
        )
      end
    end
  end
end

if defined?(::ActionController)
  ::ActiveSupport.on_load(:action_controller) do
    include ::ObjectDiffTrail::Rails::Controller
  end
end
