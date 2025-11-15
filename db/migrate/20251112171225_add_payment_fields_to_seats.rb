class AddPaymentFieldsToSeats < ActiveRecord::Migration[8.0]
  def change
    add_column :seats, :stripe_payment_intent_id, :string
    add_column :seats, :purchased_at, :datetime
  end
end
