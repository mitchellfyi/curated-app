class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :title
      t.string :url
      t.text :content
      t.belongs_to :source, null: true, foreign_key: true

      t.timestamps
    end
  end
end
