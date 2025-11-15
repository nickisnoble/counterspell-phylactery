require "yaml"

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create admins
admins = [ "nick", "marnie" ]
admins.each do |name|
  u = User.find_or_create_by(email: "#{name}@counterspell.games", display_name: name)
  u.admin!
end

# Populate lore

ancestry = <<~ANCESTRIES
- name: Ornath
  description: Sentient mechanical beings built from calderore – their true origins a mystery. Many embrace body modifications for style as well as function. Their physical form is effectively immortal as long as they acquire or craft new parts.
  abilities:
    Purposeful Design: Decide your purpose. At character creation, choose one of your Experiences that best aligns with this purpose and gain a permanent +1 bonus to it.
    Efficient: When you take a short rest, you can choose a long rest move instead of a short rest move.
- name: Vark
  description: Short humanoids (4 to 5 ½ feet) with square frames, dense musculature, and thick hair. They are often broad in proportion to their stature. Their skin and nails contain a high amount of keratin, making them naturally resilient. They prefer dwelling high in the mountains or deep into the sea.
  abilities:
    Thick Skin: When you take Minor damage, you can mark 2 Stress instead of marking a Hit Point.
    Increased Fortitude: Spend 3 Hope to halve incoming physical damage.
- name: Calderaan
  description: Typically tall and slender, these humanoids have pointed ears and acutely attuned senses. Some possess blue, green, or purple complexions – part of their ancestry on a darkened world. They rest effectively in a short amount of time by dropping into a trance.
  abilities:
    Quick Reactions: Mark a Stress to gain advantage on a reaction roll.
    Celestial Trance: During a rest, you can drop into a trance to choose an additional downtime move.
- name: Rax
  description: Towering (6 ½ to 8 ½ feet tall) ram-like creatures with broad shoulders, long arms, and beautiful horns. From a moon with high gravity, they are naturally muscular.
  abilities:
    Endurance: Gain an additional Hit Point slot at character creation.
    Reach: Treat any weapon, ability, spell, or other feature that has a Melee range as though it has a Very Close range instead.
- name: Feynor
  description: Recognized by their dexterous hands, rounded ears, and bodies built for endurance. Their average height ranges from just under 5 feet to about 6 ½ feet. Humans are physically adaptable and adjust to harsh climates with relative ease.
  abilities:
    High Stamina: Gain an additional Stress slot at character creation.
    Adaptability: When you fail a roll that utilized one of your Experiences, you can mark a Stress to reroll.
- name: Merivian
  description: Hailing from an isolated kingdom, deep within the oceans, Merivians boast a strong history of ingenuity and craft. They use special equipment to travel the lands above.
  abilities:
    Amphibious: You can breathe and move naturally underwater.
    Scales: When you would take Severe damage, you can mark a Stress to mark 1 fewer Hit Point.
- name: Kiplin
  description: Resembling opossums, Kiplins have curious eyes, nimble fingers, and prehensile tails. Their size ranges from 2 to 4 feet tall. These traits grant members of this ancestry unique agility, and they are skilled climbers.
  abilities:
    Natural Climber: You have advantage on Agility Rolls that involve balancing and climbing.
    Nimble: Gain a permanent +1 bonus to your Evasion at character creation.
ANCESTRIES


character_class = <<~CLASS
- name: "Bard / Troubadour"
  description: "Troubadours play music to bolster their allies."
- name: "Bard / Wordsmith"
  description: "Wordsmiths use clever wordplay and captivate crowds."
- name: "Druid / Warden of the Elements"
  description: "Wardens of the Elements embody the natural elements of the wild."
- name: "Druid / Warden of Renewal"
  description: "Wardens of Renewal embody the natural elements of the wild."
- name: "Guardian / Stalwart"
  description: "Stalwarts take heavy blows and keep fighting."
- name: "Guardian / Vengeance"
  description: "Vengeances strike down enemies who harm them or their allies."
- name: "Ranger / Beastbound"
  description: "Beastbounds form a deep bond with an animal ally."
- name: "Ranger / Wayfinder"
  description: "Wayfinders hunt their prey and strike with deadly force."
- name: "Rogue / Nightwalker"
  description: "Nightwalkers manipulate shadows to maneuver through the environment."
- name: "Rogue / Syndicate"
  description: "Syndicates have a web of contacts everywhere they go."
- name: "Seraph / Divine Wielder"
  description: "Divine Wielders dominate the battlefield with a legendary weapon."
- name: "Seraph / Winged Sentinel"
  description: "Winged Sentinels take flight and strike crushing blows from the sky."
- name: "Sorcerer / Elemental Origin"
  description: "Elemental Origins channel the raw power of a particular element."
- name: "Sorcerer / Primal Origin"
  description: "Primal Origins extend the versatility of their spells in powerful ways."
- name: "Warrior / Call of the Brave"
  description: "Call of the Brave use the might of their enemies to fuel their own power."
- name: "Warrior / Call of the Slayer"
  description: "Call of the Slayers strike down adversaries with immense force."
- name: "Wizard / School of Knowledge"
  description: "School of Knowledge wizards gain a keen understanding of the world around them."
- name: "Wizard / School of War"
  description: "School of War wizards utilize trained magic for violence."
CLASS

background = <<~BACKGROUND
- name: Highborne
  description: Being part of a highborne community means you're accustomed to a life of elegance, opulence, and prestige within the upper echelons of society. They place great value on titles and possessions, and their status often grants them power and influence, controlling the political and economic status of the areas in which they live.
  abilities:
    Privilege: You have advantage on rolls to consort with nobles, negotiate prices, or leverage your reputation to get what you want.
- name: Loreborne
  description: Being part of a loreborne community means you’re from a society that favors strong academic or political prowess. Loreborne communities highly value knowledge, frequently in the form of historical preservation, political advancement, scientific study, skill development, or lore and mythology compilation.
  abilities:
    Well-Read: You have advantage on rolls that involve the history, culture, or politics of a prominent person or place.
- name: Orderborne
  description: Being part of an orderborne community means you’re from a collective that focuses on discipline or faith, and you uphold a set of principles that reflect your experience there. They are frequently some of the most powerful among the surrounding communities by aligning members around a common value or goal.
  abilities:
    Dedicated: Record three sayings or values your upbringing instilled in you. Once per rest, when you describe how you’re embodying one of these principles through your current action, you can roll a d20 as your Hope Die.
- name: Ridgeborne
  description: Being part of a ridgeborne community means you’ve called the rocky peaks and sharp cliffs of the mountainside home. These groups are adept at adaptation and develop unique technologies and equipment to move across difficult terrain, making them sturdy and strong-willed.
  abilities:
    Steady: You have advantage on rolls to traverse dangerous cliffs and ledges, navigate harsh environments, and use your survival knowledge.
- name: Seaborne
  description: Being part of a seaborne community means you lived on or near a large body of water. Seaborne communities are built, both physically and culturally, around the specific waters they call home, and their members are closely tied to the ocean tides and the creatures who inhabit them.
  abilities:
    Know the Tide: You can sense the ebb and flow of life. When you roll with Fear, place a token on your community card. You can hold a number of tokens equal to your level. Before you make an action roll, you can spend any number of these tokens to gain a +1 bonus to the roll for each token spent. At the end of each session, clear all unspent tokens.
- name: Slyborne
  description: Being part of a slyborne community means you come from a group that operates outside the law, including all manner of criminals, grifters, and con artists. Members are brought together by their disreputable goals and clever means of achieving them.
  abilities:
    Scoundrel: You have advantage on rolls to negotiate with criminals, detect lies, or find a safe place to hide.
- name: Underborne
  description: Being part of an underborne community means you’re from a subterranean society. They range from small family groups in burrows to massive metropolises in caverns of stone and are recognized for their incredible boldness and skill that enable great feats of architecture and engineering.
  abilities:
    Low-Light Living: When you’re in an area with low light or heavy shadow, you have advantage on rolls to hide, investigate, or perceive details within that area.
- name: Wanderborne
  description: Being part of a wanderborne community means you’ve lived as a nomad, forgoing a permanent home and experiencing a wide variety of cultures. They put less value on the accumulation of material possessions in favor of acquiring information, skills, and connections.
  abilities:
    Nomadic Pack: Add a Nomadic Pack to your inventory. Once per session, you can spend a Hope to reach into this pack and pull out a mundane item that’s useful to your situation. Work with the GM to figure out what item you take out.
- name: Wildborne
  description: Being part of a wildborne community means you lived deep within the forest. Wildborne societies integrate their villages and cities with the natural environment and are dedicated to the conservation of their homelands.
  abilities:
    Lightfoot: Your movement is naturally silent.
BACKGROUND

datasets = {
  "Ancestry"       => ancestry,
  "Class"          => character_class,
  "Background"     => background
}

datasets.each do |type, yaml|
  YAML.safe_load(yaml, aliases: true).each do |h|
    trait = Trait.find_or_initialize_by(
      type: type,
      name: h["name"]
    )

    trait.description = h["description"]

    if h["abilities"]
      trait.abilities = h["abilities"]
    end

    trait.save!
  end
end

# Create Locations
tavern = Location.find_or_create_by(name: "The Dragon's Hoard Tavern") do |loc|
  loc.address = "123 Market Street, Waterdeep, Sword Coast"
end

guild_hall = Location.find_or_create_by(name: "Adventurer's Guild Hall") do |loc|
  loc.address = "456 Guild Square, Baldur's Gate, Sword Coast"
end

# Create Events with all statuses: planning, upcoming, past, cancelled
# Planning events
Event.find_or_create_by(name: "Quest for the Lost Artifact", location: tavern) do |event|
  event.date = 30.days.from_now.to_date
  event.status = :planning
  event.start_time = "14:00"
  event.end_time = "18:00"
  event.ticket_price = 15.00
end

Event.find_or_create_by(name: "Dragon's Lair Expedition", location: guild_hall) do |event|
  event.date = 45.days.from_now.to_date
  event.status = :planning
  event.start_time = "10:00"
  event.end_time = "16:00"
  event.ticket_price = 20.00
end

# Upcoming events
Event.find_or_create_by(name: "Festival of Heroes", location: tavern) do |event|
  event.date = 7.days.from_now.to_date
  event.status = :upcoming
  event.start_time = "18:00"
  event.end_time = "23:00"
  event.ticket_price = 10.00
end

Event.find_or_create_by(name: "Tournament of Champions", location: guild_hall) do |event|
  event.date = 14.days.from_now.to_date
  event.status = :upcoming
  event.start_time = "12:00"
  event.end_time = "20:00"
  event.ticket_price = 25.00
end

# Past events
Event.find_or_create_by(name: "Summer Solstice Celebration", location: tavern) do |event|
  event.date = 30.days.ago.to_date
  event.status = :past
  event.start_time = "19:00"
  event.end_time = "23:00"
  event.ticket_price = 12.00
end

Event.find_or_create_by(name: "Guild Founders Day", location: guild_hall) do |event|
  event.date = 60.days.ago.to_date
  event.status = :past
  event.start_time = "10:00"
  event.end_time = "17:00"
  event.ticket_price = 15.00
end

# Cancelled events
Event.find_or_create_by(name: "Cancelled: Goblin Raid Defense", location: tavern) do |event|
  event.date = 5.days.from_now.to_date
  event.status = :cancelled
  event.start_time = "15:00"
  event.end_time = "19:00"
  event.ticket_price = 10.00
end

Event.find_or_create_by(name: "Cancelled: Moonlight Market", location: guild_hall) do |event|
  event.date = 3.days.ago.to_date
  event.status = :cancelled
  event.start_time = "20:00"
  event.end_time = "02:00"
  event.ticket_price = 5.00
end

# Create GM users
gm_users = []
3.times do |i|
  u = User.find_or_create_by(email: "gm#{i + 1}@counterspell.games") do |user|
    user.display_name = "GM #{i + 1}"
  end
  u.gm! unless u.gm? || u.admin?
  gm_users << u
end

# Create some player users for seats
player_users = []
10.times do |i|
  player_users << User.find_or_create_by(email: "player#{i + 1}@counterspell.games") do |user|
    user.display_name = "Player #{i + 1}"
  end
end

# Add games and seats to events
Event.find_each do |event|
  # Skip creating games for cancelled events or if they already have games
  next if event.cancelled? || event.games.any?

  # Create 1-2 games per event
  game_count = [1, 2].sample
  game_count.times do |game_index|
    gm = gm_users.sample

    game = event.games.create!(
      gm: gm,
      seat_count: [4, 5, 6].sample
    )

    # Create empty seats for the game
    game.seat_count.times do
      game.seats.create!
    end
  end
end

# Fill some seats for past and upcoming events (only if seats are empty)
Event.where(status: [:past, :upcoming]).find_each do |event|
  # Track which players are already assigned to this event
  assigned_players = event.games.joins(:seats).where.not(seats: { user_id: nil }).pluck('seats.user_id').uniq
  available_players = player_users.reject { |p| assigned_players.include?(p.id) }

  event.games.each do |game|
    empty_seats = game.seats.where(user_id: nil)
    next if empty_seats.empty? || available_players.empty?

    # Fill half to all-but-one seats, but don't exceed available players
    filled_count = [[empty_seats.count / 2, empty_seats.count - 1].sample, available_players.count].min

    empty_seats.limit(filled_count).each do |seat|
      player = available_players.shift
      seat.update!(user: player) if player
    end
  end
end
