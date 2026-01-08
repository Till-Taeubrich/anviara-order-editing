class FulfillmentOrder < ApplicationRecord
  belongs_to :shop
  belongs_to :order, optional: true

  validates :shopify_id, presence: true, uniqueness: true
  validates :status, presence: true
end
