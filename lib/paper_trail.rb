require "request_store"
require "object_diff_trail/cleaner"
require "object_diff_trail/config"
require "object_diff_trail/has_object_diff_trail"
require "object_diff_trail/record_history"
require "object_diff_trail/reifier"
require "object_diff_trail/version_association_concern"
require "object_diff_trail/version_concern"
require "object_diff_trail/version_number"
require "object_diff_trail/serializers/json"
require "object_diff_trail/serializers/yaml"

# An ActiveRecord extension that tracks changes to your models, for auditing or
# versioning.
module ObjectDiffTrail
  extend ObjectDiffTrail::Cleaner

  class << self
    # @api private
    def clear_transaction_id
      self.transaction_id = nil
    end

    # Switches ObjectDiffTrail on or off.
    # @api public
    def enabled=(value)
      ObjectDiffTrail.config.enabled = value
    end

    # Returns `true` if ObjectDiffTrail is on, `false` otherwise.
    # ObjectDiffTrail is enabled by default.
    # @api public
    def enabled?
      !!ObjectDiffTrail.config.enabled
    end

    # Sets whether ObjectDiffTrail is enabled or disabled for the current request.
    # @api public
    def enabled_for_controller=(value)
      object_diff_trail_store[:request_enabled_for_controller] = value
    end

    # Returns `true` if ObjectDiffTrail is enabled for the request, `false` otherwise.
    #
    # See `ObjectDiffTrail::Rails::Controller#object_diff_trail_enabled_for_controller`.
    # @api public
    def enabled_for_controller?
      !!object_diff_trail_store[:request_enabled_for_controller]
    end

    # Sets whether ObjectDiffTrail is enabled or disabled for this model in the
    # current request.
    # @api public
    def enabled_for_model(model, value)
      object_diff_trail_store[:"enabled_for_#{model}"] = value
    end

    # Returns `true` if ObjectDiffTrail is enabled for this model in the current
    # request, `false` otherwise.
    # @api public
    def enabled_for_model?(model)
      !!object_diff_trail_store.fetch(:"enabled_for_#{model}", true)
    end

    # Returns a `::Gem::Version`, convenient for comparisons. This is
    # recommended over `::ObjectDiffTrail::VERSION::STRING`.
    # @api public
    def gem_version
      ::Gem::Version.new(VERSION::STRING)
    end

    # Set the field which records when a version was created.
    # @api public
    def timestamp_field=(_field_name)
      raise(
        "ObjectDiffTrail.timestamp_field= has been removed, without replacement. " \
          "It is no longer configurable. The timestamp field in the versions table " \
          "must now be named created_at."
      )
    end

    # Sets who is responsible for any changes that occur. You would normally use
    # this in a migration or on the console, when working with models directly.
    # In a controller it is set automatically to the `current_user`.
    # @api public
    def whodunnit=(value)
      object_diff_trail_store[:whodunnit] = value
    end

    # If nothing passed, returns who is reponsible for any changes that occur.
    #
    #   ObjectDiffTrail.whodunnit = "someone"
    #   ObjectDiffTrail.whodunnit # => "someone"
    #
    # If value and block passed, set this value as whodunnit for the duration of the block
    #
    #   ObjectDiffTrail.whodunnit("me") do
    #     puts ObjectDiffTrail.whodunnit # => "me"
    #   end
    #
    # @api public
    def whodunnit(value = nil)
      if value
        raise ArgumentError, "no block given" unless block_given?

        previous_whodunnit = object_diff_trail_store[:whodunnit]
        object_diff_trail_store[:whodunnit] = value

        begin
          yield
        ensure
          object_diff_trail_store[:whodunnit] = previous_whodunnit
        end
      elsif object_diff_trail_store[:whodunnit].respond_to?(:call)
        object_diff_trail_store[:whodunnit].call
      else
        object_diff_trail_store[:whodunnit]
      end
    end

    # Sets any information from the controller that you want ObjectDiffTrail to
    # store.  By default this is set automatically by a before filter.
    # @api public
    def controller_info=(value)
      object_diff_trail_store[:controller_info] = value
    end

    # Returns any information from the controller that you want
    # ObjectDiffTrail to store.
    #
    # See `ObjectDiffTrail::Rails::Controller#info_for_object_diff_trail`.
    # @api public
    def controller_info
      object_diff_trail_store[:controller_info]
    end

    # Getter and Setter for ObjectDiffTrail Serializer
    # @api public
    def serializer=(value)
      ObjectDiffTrail.config.serializer = value
    end

    # @api public
    def serializer
      ObjectDiffTrail.config.serializer
    end

    # @api public
    def transaction?
      ::ActiveRecord::Base.connection.open_transactions > 0
    end

    # @api public
    def transaction_id
      object_diff_trail_store[:transaction_id]
    end

    # @api public
    def transaction_id=(id)
      object_diff_trail_store[:transaction_id] = id
    end

    # Thread-safe hash to hold ObjectDiffTrail's data. Initializing with needed
    # default values.
    # @api private
    def object_diff_trail_store
      RequestStore.store[:object_diff_trail] ||= { request_enabled_for_controller: true }
    end

    # Returns ObjectDiffTrail's configuration object.
    # @api private
    def config
      @config ||= ObjectDiffTrail::Config.instance
      yield @config if block_given?
      @config
    end
    alias configure config

    def version
      VERSION::STRING
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include ObjectDiffTrail::Model
end

# Require frameworks
if defined?(::Rails) && ActiveRecord::VERSION::STRING >= "3.2"
  require "object_diff_trail/frameworks/rails"
else
  require "object_diff_trail/frameworks/active_record"
end
