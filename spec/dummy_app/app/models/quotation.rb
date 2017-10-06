class Quotation < ActiveRecord::Base
  belongs_to :chapter
  has_many :citations, dependent: :destroy
  has_object_diff_trail
end
