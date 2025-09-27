class RenameTermsToPages < ActiveRecord::Migration[8.0]
  def change
    rename_table :terms, :pages
  end
end
