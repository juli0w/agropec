class AddCashToClients < ActiveRecord::Migration[5.0]
  def change
    add_column :clients, :cash, :decimal, :precision => 8, :scale => 2
  end
end
