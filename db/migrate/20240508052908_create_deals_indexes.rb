class CreateDealsIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :deals, %i[company_id amount]
  end
end
