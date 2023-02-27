class CreateSources < ActiveRecord::Migration[7.0]
  def change
    create_table(:sources, id: :uuid) do |t|
      t.belongs_to :account, null: false, foreign_key: true, type: :uuid

      t.string :name
      t.string :url
      t.text :keyphrases, array: true, default: []

      t.datetime :fetched_at
      t.timestamps
    end
  end
end
