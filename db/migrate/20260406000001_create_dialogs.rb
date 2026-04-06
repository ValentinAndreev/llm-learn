class CreateDialogs < ActiveRecord::Migration[8.1]
  def change
    create_table :dialogs do |t|
      t.string :title, null: false
      t.timestamps
    end
  end
end
