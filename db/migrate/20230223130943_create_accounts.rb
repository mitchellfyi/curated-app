class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table(:accounts, id: :uuid) do |t|
      t.string :name
      t.string :subdomain
      t.string :domain
      t.text :keyphrases, array: true, default: []

      t.timestamps
    end
  end
end
