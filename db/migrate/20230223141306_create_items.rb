class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.belongs_to :account, null: false, foreign_key: true
      t.belongs_to :source, null: true, foreign_key: true

      t.string :title
      t.string :url
      t.text :content

      t.timestamps
    end
  end
end
