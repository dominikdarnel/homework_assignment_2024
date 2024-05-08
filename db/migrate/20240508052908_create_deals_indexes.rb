class CreateDealsIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :deals, :amount
  end
end
