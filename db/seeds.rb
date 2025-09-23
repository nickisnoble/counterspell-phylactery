# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create admins
[ "nick", "marnie" ].each do |name|
  u = User.create!(email: "#{name}@counterspell.games")
  u.admin!
end

# Populate lore
