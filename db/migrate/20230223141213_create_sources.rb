class CreateSources < ActiveRecord::Migration[7.0]
  def change
    create_table :sources do |t|
      t.belongs_to :account, null: false, foreign_key: true

      t.string :title
      t.string :url

      t.datetime :fetched_at
      t.timestamps
    end
  end
end
