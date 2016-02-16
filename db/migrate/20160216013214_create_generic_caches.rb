class CreateGenericCaches < ActiveRecord::Migration
  def change
    create_table :generic_caches do |t|
      t.string :title
      t.text :content
      t.string :category
      t.timestamps null: false
    end
  end
end
