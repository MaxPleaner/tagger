class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :relation_type
      t.integer :relation_id
      t.string :title
    end
  end
end
