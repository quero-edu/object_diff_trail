require "singleton"
require "object_diff_trail/serializers/yaml"

module ObjectDiffTrail
  # Global configuration affecting all threads. Some thread-specific
  # configuration can be found in `object_diff_trail.rb`, others in `controller.rb`.
  class Config
    include Singleton
    attr_accessor :serializer, :version_limit
    attr_writer :track_associations

    def initialize
      # Variables which affect all threads, whose access is synchronized.
      @mutex = Mutex.new
      @enabled = true

      # Variables which affect all threads, whose access is *not* synchronized.
      @serializer = ObjectDiffTrail::Serializers::YAML
    end

    # Previously, we checked `ObjectDiffTrail::VersionAssociation.table_exists?`
    # here, but that proved to be problematic in situations when the database
    # connection had not been established, or when the database does not exist
    # yet (as with `rake db:create`).
    def track_associations?
      if @track_associations.nil?
        ActiveSupport::Deprecation.warn <<-EOS.strip_heredoc.gsub(/\s+/, " ")
          ObjectDiffTrail.config.track_associations has not been set. As of ObjectDiffTrail 5, it
          defaults to false. Tracking associations is an experimental feature so
          we recommend setting ObjectDiffTrail.config.track_associations = false in
          your config/initializers/object_diff_trail.rb
        EOS
        false
      else
        @track_associations
      end
    end

    # Indicates whether ObjectDiffTrail is on or off. Default: true.
    def enabled
      @mutex.synchronize { !!@enabled }
    end

    def enabled=(enable)
      @mutex.synchronize { @enabled = enable }
    end
  end
end
