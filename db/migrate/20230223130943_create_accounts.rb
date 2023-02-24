class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table(:accounts, id: :uuid) do |t|
      t.string :subdomain
      t.string :domain

      t.timestamps
    end
  end
end
