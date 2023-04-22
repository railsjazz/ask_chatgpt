class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :title
      t.integer :author_id
      t.string :status

      t.timestamps
    end
  end
end
