class UpdateHeroRolesToNewValues < ActiveRecord::Migration[8.0]
  def up
    # Map old role values to new ones
    # fighter -> striker
    # wild_card -> charmer
    # protector and strategist remain the same

    execute <<-SQL
      UPDATE heroes SET role = 'striker' WHERE role = 'fighter';
      UPDATE heroes SET role = 'charmer' WHERE role = 'wild_card';
    SQL
  end

  def down
    # Reverse the mapping
    execute <<-SQL
      UPDATE heroes SET role = 'fighter' WHERE role = 'striker';
      UPDATE heroes SET role = 'wild_card' WHERE role = 'charmer';
    SQL
  end
end
