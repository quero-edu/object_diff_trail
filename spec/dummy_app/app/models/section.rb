class Section < ActiveRecord::Base
  belongs_to :chapter
  has_many :paragraphs, dependent: :destroy

  has_object_diff_trail
end
