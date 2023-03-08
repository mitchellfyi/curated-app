class CreateSources < ActiveRecord::Migration[7.0]
  def change
    create_table(:sources, id: :uuid) do |t|
      t.belongs_to :collection, null: false, foreign_key: true, type: :uuid

      t.string :name
      t.string :url
      t.text :keyphrases, array: true, default: []

      t.timestamps
      t.datetime :fetched_at
    end
  end
end
