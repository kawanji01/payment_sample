class Unit < ApplicationRecord
  belongs_to :plan
  has_many :unit_purchases
end
