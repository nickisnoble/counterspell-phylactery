class AddSlugToUsers < ActiveRecord::Migration[8.0]
  def up
    # add as nullable
    add_column :users, :slug, :string

    # ad public id
    say_with_time "Backfilling users.slug" do
      User.reset_column_information
      User.where(slug: nil).find_each do |u|
        u.update_columns(slug: generate_unique_token_for(User))
      end
    end

    # make un-nullable after all Users have the field
    change_column_null :users, :slug, false

    add_index :users, :slug, unique: true
  end

  def down
    remove_index  :users, :slug
    remove_column :users, :slug
  end

  private

  # Simple, fast uniqueness check for the backfill step
  def generate_unique_token_for(klass, length = 8)
    loop do
      token = SecureRandom.base58(length)
      break token unless klass.exists?(slug: token)
    end
  end
end
