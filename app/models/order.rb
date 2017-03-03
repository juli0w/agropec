class Order < ApplicationRecord
  has_many :order_items
  belongs_to :user, optional: true

  scope :open, -> { where(state: "open") }
  scope :paid, -> { where(state: "paid") }

  def empty?
    order_items.count <= 0
  end

  def open!
    update(state: "open",
           total: calculate_total)
  end

  def pay!
    update(state: "paid")
  end

  def cancel!
    update(state: "canceled")
  end

  def add_item params
    order_item = order_items.select { |oi| oi.item_id == params[:item_id].to_i }.first
    qty = (params[:quantity].to_i > 0) ? params[:quantity].to_i : 1

    unless order_item.blank?
      order_item.quantity += qty
    else
      order_item = order_items.new(item_id: params[:item_id], quantity: qty)
    end

    order_item.save
    return order_item
  end

  def calculate_total
    @total = order_items.collect { |oi| oi.valid? ? (oi.quantity * oi.unit_price) : 0 }.sum
  end
end
