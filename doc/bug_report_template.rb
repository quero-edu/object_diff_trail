# Use this template to report ObjectDiffTrail bugs.
# Please include only the minimum code necessary to reproduce your issue.
require "bundler/inline"

# STEP ONE: What versions are you using?
gemfile(true) do
  ruby "2.4.2"
  source "https://rubygems.org"
  gem "activerecord", "5.1.4"
  gem "minitest", "5.10.3"
  gem "object_diff_trail", "8.0.0", require: false
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# Please use sqlite for your bug reports, if possible.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = nil
ActiveRecord::Schema.define do
  # STEP TWO: Define your tables here.
  create_table :users, force: true do |t|
    t.text :first_name, null: false
    t.timestamps null: false
  end

  create_table :versions do |t|
    t.string :item_type, null: false
    t.integer :item_id, null: false
    t.string :event, null: false
    t.string :whodunnit
    t.text :object, limit: 1_073_741_823
    t.text :object_changes, limit: 1_073_741_823
    t.integer :transaction_id
    t.datetime :created_at
  end
  add_index :versions, %i[item_type item_id]
  add_index :versions, [:transaction_id]

  create_table :version_associations do |t|
    t.integer  :version_id
    t.string   :foreign_key_name, null: false
    t.integer  :foreign_key_id
  end
  add_index :version_associations, [:version_id]
  add_index :version_associations, %i[foreign_key_name foreign_key_id],
    name: "index_version_associations_on_foreign_key"
end
ActiveRecord::Base.logger = Logger.new(STDOUT)
require "object_diff_trail/config"

# STEP THREE: Configure ObjectDiffTrail as you would in your initializer
ObjectDiffTrail::Config.instance.track_associations = true

require "object_diff_trail"

# STEP FOUR: Define your AR models here.
class User < ActiveRecord::Base
  has_object_diff_trail
end

# STEP FIVE: Please write a test that demonstrates your issue.
class BugTest < ActiveSupport::TestCase
  def test_1
    assert_difference(-> { ObjectDiffTrail::Version.count }, +1) {
      User.create(first_name: "Jane")
    }
  end
end

# STEP SIX: Run this script using `ruby my_bug_report.rb`
