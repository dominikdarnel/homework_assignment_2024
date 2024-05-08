class CreateCompaniesIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :companies, :name
    add_index :companies, :industry
    add_index :companies, :employee_count
    add_index :companies, :created_at
  end
end
