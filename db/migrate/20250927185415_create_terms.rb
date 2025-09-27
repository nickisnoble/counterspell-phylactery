class CreateTerms < ActiveRecord::Migration[8.0]
  def change
    create_table :terms do |t|
      t.string :title
      t.string :slug

      t.timestamps
    end
  end
end
