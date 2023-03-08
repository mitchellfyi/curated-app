class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table(:items, id: :uuid) do |t|
      t.belongs_to :account, null: false, foreign_key: true, type: :uuid
      t.belongs_to :source, null: true, foreign_key: true, type: :uuid

      t.string :title
      t.string :url
      t.text :content

      t.timestamps
      t.datetime :fetched_at
    end
  end
end
