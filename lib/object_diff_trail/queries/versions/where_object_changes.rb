module ObjectDiffTrail
  module Queries
    module Versions
      # For public API documentation, see `where_object` in
      # `object_diff_trail/version_concern.rb`.
      # @api private
      class WhereObjectChanges
        # - version_model_class - The class that VersionConcern was mixed into.
        # - attributes - A `Hash` of attributes and values. See the public API
        #   documentation for details.
        # @api private
        def initialize(version_model_class, attributes)
          @version_model_class = version_model_class

          # Currently, this `deep_dup` is necessary because the `jsonb` branch
          # modifies `@attributes`, and that would be a nasty suprise for
          # consumers of this class.
          # TODO: Stop modifying `@attributes`, then remove `deep_dup`.
          @attributes = attributes.deep_dup
        end

        # @api private
        def execute
          case @version_model_class.columns_hash["object_changes"].type
          when :jsonb
            jsonb
          when :json
            json
          else
            text
          end
        end

        private

        # @api private
        def json
          predicates = []
          values = []
          @attributes.each do |field, value|
            predicates.push(
              "((object_changes->>? ILIKE ?) OR (object_changes->>? ILIKE ?))"
            )
            values.concat([field, "[#{value.to_json},%", field, "[%,#{value.to_json}]%"])
          end
          sql = predicates.join(" and ")
          @version_model_class.where(sql, *values)
        end

        # @api private
        def jsonb
          @attributes.each { |field, value| @attributes[field] = [value] }
          @version_model_class.where("object_changes @> ?", @attributes.to_json)
        end

        # @api private
        def text
          arel_field = @version_model_class.arel_table[:object_changes]
          where_conditions = @attributes.map { |field, value|
            ::ObjectDiffTrail.serializer.where_object_changes_condition(arel_field, field, value)
          }
          where_conditions = where_conditions.reduce { |a, e| a.and(e) }
          @version_model_class.where(where_conditions)
        end
      end
    end
  end
end