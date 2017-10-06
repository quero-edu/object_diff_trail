require "spec_helper"

module ObjectDiffTrail
  ::RSpec.describe Version, type: :model do
    describe "object_changes column", versioning: true do
      let(:widget) { Widget.create!(name: "Dashboard") }
      let(:value) { widget.versions.last.object_changes }

      context "serializer is YAML" do
        specify { expect(ObjectDiffTrail.serializer).to be ObjectDiffTrail::Serializers::YAML }

        it "store out as a plain hash" do
          expect(value =~ /HashWithIndifferentAccess/).to be_nil
        end
      end

      context "serializer is JSON" do
        before(:all) { ObjectDiffTrail.serializer = ObjectDiffTrail::Serializers::JSON }

        it "store out as a plain hash" do
          expect(value =~ /HashWithIndifferentAccess/).to be_nil
        end

        after(:all) { ObjectDiffTrail.serializer = ObjectDiffTrail::Serializers::YAML }
      end
    end

    describe "#object_diff_trail_originator" do
      context "no previous versions" do
        it "returns nil" do
          expect(ObjectDiffTrail::Version.new.object_diff_trail_originator).to be_nil
        end
      end

      context "has previous version", versioning: true do
        it "returns name of whodunnit" do
          name = FFaker::Name.name
          widget = Widget.create!(name: FFaker::Name.name)
          widget.versions.first.update_attributes!(whodunnit: name)
          widget.update_attributes!(name: FFaker::Name.first_name)
          expect(widget.versions.last.object_diff_trail_originator).to eq(name)
        end
      end
    end

    describe "#previous" do
      context "no previous versions" do
        it "returns nil" do
          expect(ObjectDiffTrail::Version.new.previous).to be_nil
        end
      end

      context "has previous version", versioning: true do
        it "returns a ObjectDiffTrail::Version" do
          name = FFaker::Name.name
          widget = Widget.create!(name: FFaker::Name.name)
          widget.versions.first.update_attributes!(whodunnit: name)
          widget.update_attributes!(name: FFaker::Name.first_name)
          expect(widget.versions.last.previous).to be_instance_of(ObjectDiffTrail::Version)
        end
      end
    end

    describe "#originator" do
      it "sets the invoke `object_diff_trail_originator`" do
        allow(ActiveSupport::Deprecation).to receive(:warn)
        subject = ObjectDiffTrail::Version.new
        allow(subject).to receive(:object_diff_trail_originator)
        subject.originator
        expect(subject).to have_received(:object_diff_trail_originator)
      end

      it "displays a deprecation warning" do
        allow(ActiveSupport::Deprecation).to receive(:warn)
        ObjectDiffTrail::Version.new.originator
        expect(ActiveSupport::Deprecation).to have_received(:warn).
          with(/Use object_diff_trail_originator instead of originator/)
      end
    end

    describe "#terminator" do
      it "is an alias for the `whodunnit` attribute" do
        attributes = { whodunnit: FFaker::Name.first_name }
        subject = ObjectDiffTrail::Version.new(attributes)
        expect(subject.terminator).to eq(attributes[:whodunnit])
      end
    end

    describe "#version_author" do
      it "is an alias for the `terminator` method" do
        subject = ObjectDiffTrail::Version.new
        expect(subject.method(:version_author)).to eq(subject.method(:terminator))
      end
    end

    describe "Methods" do
      # TODO: Changing the data type of these database columns in the middle
      # of the test suite adds a fair amount of complication. Is there a better
      # way? We already have a `json_versions` table in our tests, maybe we
      # could use that and add a `jsonb_versions` table?
      column_overrides = [false]
      if ENV["DB"] == "postgres" && ::ActiveRecord::VERSION::MAJOR >= 4
        column_overrides << "json"
        # 'jsonb' column types are only supported for ActiveRecord 4.2+
        column_overrides << "jsonb" if ::ActiveRecord::VERSION::STRING >= "4.2"
      end

      column_overrides.shuffle.each do |column_datatype_override|
        context "with a #{column_datatype_override || 'text'} column" do
          before do
            if column_datatype_override
              # In rails < 5, we use truncation, ie. there is no transaction
              # around the tests, so we can't use a savepoint.
              if active_record_gem_version >= ::Gem::Version.new("5")
                ActiveRecord::Base.connection.execute("SAVEPOINT pgtest;")
              end
              %w[object object_changes].each do |column|
                ActiveRecord::Base.connection.execute(
                  "ALTER TABLE versions DROP COLUMN #{column};"
                )
                ActiveRecord::Base.connection.execute(
                  "ALTER TABLE versions ADD COLUMN #{column} #{column_datatype_override};"
                )
              end
              ObjectDiffTrail::Version.reset_column_information
            end
          end

          after do
            if column_datatype_override
              # In rails < 5, we use truncation, ie. there is no transaction
              # around the tests, so we can't use a savepoint.
              if active_record_gem_version >= ::Gem::Version.new("5")
                ActiveRecord::Base.connection.execute("ROLLBACK TO SAVEPOINT pgtest;")
              else
                %w[object object_changes].each do |column|
                  ActiveRecord::Base.connection.execute(
                    "ALTER TABLE versions DROP COLUMN #{column};"
                  )
                  ActiveRecord::Base.connection.execute(
                    "ALTER TABLE versions ADD COLUMN #{column} text;"
                  )
                end
              end
              ObjectDiffTrail::Version.reset_column_information
            end
          end

          describe "#where_object", versioning: true do
            let(:widget) { Widget.new }
            let(:name) { FFaker::Name.first_name }
            let(:int) { rand(10) + 1 }

            before do
              widget.update_attributes!(name: name, an_integer: int)
              widget.update_attributes!(name: "foobar", an_integer: 100)
              widget.update_attributes!(name: FFaker::Name.last_name, an_integer: 15)
            end

            it "requires its argument to be a Hash" do
              expect {
                ObjectDiffTrail::Version.where_object(:foo)
              }.to raise_error(ArgumentError)
              expect {
                ObjectDiffTrail::Version.where_object([])
              }.to raise_error(ArgumentError)
            end

            context "`serializer == YAML`" do
              specify do
                expect(ObjectDiffTrail.serializer).to be ObjectDiffTrail::Serializers::YAML
              end

              it "locates versions according to their `object` contents" do
                expect(
                  ObjectDiffTrail::Version.where_object(name: name)
                ).to eq([widget.versions[1]])
                expect(
                  ObjectDiffTrail::Version.where_object(an_integer: 100)
                ).to eq([widget.versions[2]])
              end
            end

            context "JSON serializer" do
              before(:all) do
                ObjectDiffTrail.serializer = ObjectDiffTrail::Serializers::JSON
              end

              specify do
                expect(ObjectDiffTrail.serializer).to be ObjectDiffTrail::Serializers::JSON
              end

              it "locates versions according to their `object` contents" do
                expect(
                  ObjectDiffTrail::Version.where_object(name: name)
                ).to eq([widget.versions[1]])
                expect(
                  ObjectDiffTrail::Version.where_object(an_integer: 100)
                ).to eq([widget.versions[2]])
              end

              after(:all) do
                ObjectDiffTrail.serializer = ObjectDiffTrail::Serializers::YAML
              end
            end
          end

          describe "#where_object_changes", versioning: true do
            let(:widget) { Widget.new }
            let(:name) { FFaker::Name.first_name }
            let(:int) { rand(5) + 2 }

            before do
              widget.update_attributes!(name: name, an_integer: 0)
              widget.update_attributes!(name: "foobar", an_integer: 77)
              widget.update_attributes!(name: FFaker::Name.last_name, an_integer: int)
            end

            it "requires its argument to be a Hash" do
              expect {
                ObjectDiffTrail::Version.where_object_changes(:foo)
              }.to raise_error(ArgumentError)
              expect {
                ObjectDiffTrail::Version.where_object_changes([])
              }.to raise_error(ArgumentError)
            end

            context "YAML serializer" do
              it "locates versions according to their `object_changes` contents" do
                expect(
                  widget.versions.where_object_changes(name: name)
                ).to eq(widget.versions[0..1])
                expect(
                  widget.versions.where_object_changes(an_integer: 77)
                ).to eq(widget.versions[1..2])
                expect(
                  widget.versions.where_object_changes(an_integer: int)
                ).to eq([widget.versions.last])
              end

              it "handles queries for multiple attributes" do
                expect(
                  widget.versions.where_object_changes(an_integer: 77, name: "foobar")
                ).to eq(widget.versions[1..2])
              end
            end

            # Only test the JSON serializer against where_object_changes
            # for json and jsonb columns, not for text columns, which are
            # no longer supported.
            if column_datatype_override
              context "JSON serializer" do
                before(:all) { ObjectDiffTrail.serializer = ObjectDiffTrail::Serializers::JSON }

                it "locates versions according to their `object_changes` contents" do
                  expect(
                    widget.versions.where_object_changes(name: name)
                  ).to eq(widget.versions[0..1])
                  expect(
                    widget.versions.where_object_changes(an_integer: 77)
                  ).to eq(widget.versions[1..2])
                  expect(
                    widget.versions.where_object_changes(an_integer: int)
                  ).to eq([widget.versions.last])
                end

                it "handles queries for multiple attributes" do
                  expect(
                    widget.versions.where_object_changes(an_integer: 77, name: "foobar")
                  ).to eq(widget.versions[1..2])
                end

                after(:all) { ObjectDiffTrail.serializer = ObjectDiffTrail::Serializers::YAML }
              end
            end
          end
        end
      end
    end
  end
end
