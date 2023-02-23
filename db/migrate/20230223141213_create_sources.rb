class CreateSources < ActiveRecord::Migration[7.0]
  def change
    create_table :sources do |t|
      t.string :title
      t.string :url

      t.timestamps
    end
  end
end
