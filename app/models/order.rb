class Order < ApplicationRecord
  belongs_to :shop
  has_many :fulfillment_orders, dependent: :destroy

  validates :shopify_id, presence: true, uniqueness: true
end
