require "yaml"

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create admins (runs in all environments)
admins = [ "nick", "marnie" ]
admins.each do |name|
  u = User.find_or_create_by(email: "#{name}@counterspell.games", display_name: name)
  u.admin!
end

# Exit early if not in development
unless Rails.env.development?
  puts "Skipping development seeds (not in development environment)"
  return
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
- name: Freynor
  description: Recognized by their dexterous hands, rounded ears, and bodies built for endurance. Their average height ranges from just under 5 feet to about 6 ½ feet. Humans are physically adaptable and adjust to harsh climates with relative ease.
  abilities:
    High Stamina: Gain an additional Stress slot at character creation.
    Adaptability: When you fail a roll that utilized one of your Experiences, you can mark a Stress to reroll.
- name: Caldeynor
  description: A hybrid ancestry combining the traits of both Calderaan and Freynor lineages.
  abilities:
    Versatile: Gain an additional Experience slot at character creation.
    Hybrid Vigor: You have advantage on rolls to resist environmental effects.
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
tavern.update!(about: "<p>A cozy establishment with warm fireplaces and the lingering scent of roasted meats. The walls are adorned with trophies from legendary adventures, and the proprietor claims a real dragon once stored its hoard in the basement. Whether true or not, adventurers gather here to share tales, plan expeditions, and enjoy the finest ale this side of the Sword Coast.</p><p>Live music every Thursday evening, featuring local bards and traveling minstrels.</p>")

guild_hall = Location.find_or_create_by(name: "Adventurer's Guild Hall") do |loc|
  loc.address = "456 Guild Square, Baldur's Gate, Sword Coast"
end
guild_hall.update!(about: "<p>The official headquarters for registered adventurers in the region. This grand stone building features a quest board updated daily, a well-stocked armory, and training facilities for honing combat skills. Guild members benefit from exclusive contracts, legal protection, and access to the extensive archives documenting centuries of completed quests.</p><p>New members welcome - registration fee waived for veterans of notable campaigns.</p>")

# Create Events with all statuses: planning, upcoming, past, cancelled
# Planning events
planning_artifact = Event.find_or_create_by(name: "Quest for the Lost Artifact", location: tavern) do |event|
  event.date = 30.days.from_now.to_date
  event.status = :planning
  event.start_time = "14:00"
  event.end_time = "18:00"
  event.ticket_price = 15.00
end
planning_artifact.update!(description: "<p>Join us for an exciting quest to recover the legendary <strong>Amulet of Whispers</strong>, last seen in the ruins beneath the Cragmaw Mountains. Rumor has it the amulet grants its wearer the ability to understand any spoken language.</p><p><strong>What to expect:</strong></p><ul><li>Dungeon exploration and puzzle solving</li><li>Roleplay-heavy social encounters</li><li>Moderate combat difficulty</li><li>Recommended for characters level 3-5</li></ul>")

planning_dragon = Event.find_or_create_by(name: "Dragon's Lair Expedition", location: guild_hall) do |event|
  event.date = 45.days.from_now.to_date
  event.status = :planning
  event.start_time = "10:00"
  event.end_time = "16:00"
  event.ticket_price = 20.00
end
planning_dragon.update!(description: "<p>An epic expedition into the lair of Vermithrax the Ancient, a red dragon who has terrorized the countryside for centuries. This is a high-stakes adventure not for the faint of heart.</p><p><strong>Adventure details:</strong></p><ul><li>Full day session with breaks for lunch</li><li>Heavy combat focus with tactical challenges</li><li>Bring your A-game and your best character sheets</li><li>Recommended for experienced players, levels 8-10</li></ul><p><em>Note: Character death is possible. Come prepared!</em></p>")

# Upcoming events - ONE WILL BE SET TO TODAY
festival = Event.find_or_create_by(name: "Festival of Heroes", location: tavern) do |event|
  event.status = :upcoming
  event.start_time = "18:00"
  event.end_time = "23:00"
  event.ticket_price = 10.00
end
# ALWAYS update the date to today, even if record already exists
festival.update!(
  date: Date.today,  # THIS ONE IS ALWAYS TODAY (using system timezone, not UTC)
  description: "<p>Celebrate the brave heroes who protect our realm! This evening festival features food, drink, music, and games of skill. All adventurers are welcome to participate in friendly competitions and share tales of glory.</p><p><strong>Festival activities:</strong></p><ul><li>Archery competition (6:00 PM)</li><li>Storytelling contest (7:30 PM)</li><li>Live music from the Wandering Minstrels (9:00 PM)</li><li>Arm wrestling tournament (10:00 PM)</li></ul><p>Prizes for winners! <strong>Family-friendly event.</strong></p>"
)

tournament = Event.find_or_create_by(name: "Tournament of Champions", location: guild_hall) do |event|
  event.date = 14.days.from_now.to_date
  event.status = :upcoming
  event.start_time = "12:00"
  event.end_time = "20:00"
  event.ticket_price = 25.00
end
tournament.update!(description: "<p>The annual Tournament of Champions returns! Watch or participate as the realm's finest warriors compete in single combat for glory, gold, and the title of Champion.</p><p><strong>Tournament format:</strong></p><ul><li>Single elimination brackets</li><li>Non-lethal combat (magical healing available)</li><li>All fighting styles welcome</li><li>Grand prize: 500 gold pieces and a masterwork weapon</li></ul><p>Spectators welcome! Betting encouraged (within reason).</p>")

# Past events
solstice = Event.find_or_create_by(name: "Summer Solstice Celebration", location: tavern) do |event|
  event.date = 30.days.ago.to_date
  event.status = :past
  event.start_time = "19:00"
  event.end_time = "23:00"
  event.ticket_price = 12.00
end
solstice.update!(description: "<p>We celebrated the longest day of the year with music, dancing, and feasting. The bonfire burned bright as adventurers from across the land gathered to honor the summer sun. Special thanks to the Wildborne druids who blessed the gathering with their nature magic.</p>")

founders = Event.find_or_create_by(name: "Guild Founders Day", location: guild_hall) do |event|
  event.date = 60.days.ago.to_date
  event.status = :past
  event.start_time = "10:00"
  event.end_time = "17:00"
  event.ticket_price = 15.00
end
founders.update!(description: "<p>A day to remember the founding of the Adventurer's Guild 200 years ago. We honored the original founders with ceremonies, shared stories of legendary quests, and inducted this year's class of new guild members. The archives were opened for public viewing, revealing artifacts from the guild's storied history.</p>")

# Cancelled events
cancelled_raid = Event.find_or_create_by(name: "Cancelled: Goblin Raid Defense", location: tavern) do |event|
  event.date = 5.days.from_now.to_date
  event.status = :cancelled
  event.start_time = "15:00"
  event.end_time = "19:00"
  event.ticket_price = 10.00
end
cancelled_raid.update!(description: "<p><strong>EVENT CANCELLED:</strong> The goblin threat was resolved peacefully through diplomatic negotiations led by Guildmaster Thornwood. No defensive action required. We apologize for any inconvenience.</p><p>Refunds have been processed automatically.</p>")

cancelled_market = Event.find_or_create_by(name: "Cancelled: Moonlight Market", location: guild_hall) do |event|
  event.date = 3.days.ago.to_date
  event.status = :cancelled
  event.start_time = "20:00"
  event.end_time = "02:00"
  event.ticket_price = 5.00
end
cancelled_market.update!(description: "<p><strong>EVENT CANCELLED:</strong> Due to unexpected weather conditions (localized temporal storm), the Moonlight Market has been postponed. We are working with vendors to reschedule for next month.</p><p>Keep an eye on our event board for the new date!</p>")

# Create GM users with muppet names first (so we can reassign games)
gm_data = [
  { email: "kermit@counterspell.games", name: "Kermit", bio: "<p>Long-time game master with a passion for swamp-based adventures. Known for balanced encounters and memorable NPCs. <em>\"It's not easy being green... or a GM!\"</em></p>" },
  { email: "gonzo@counterspell.games", name: "Gonzo", bio: "<p>Specializes in high-chaos, unpredictable campaigns where anything can happen. Loves incorporating bizarre plot twists and experimental mechanics. Former stunt performer turned storyteller.</p>" },
  { email: "fozzie@counterspell.games", name: "Fozzie", bio: "<p>Runs lighthearted, comedy-focused games perfect for new players. Every session includes at least three terrible puns. <em>\"Wocka wocka!\"</em> Currently running a campaign about traveling bards.</p>" }
]

gm_users = []
gm_data.each do |gm|
  u = User.find_or_create_by(email: gm[:email]) do |user|
    user.display_name = gm[:name]
  end
  u.update!(bio: gm[:bio])
  u.gm! unless u.gm? || u.admin?
  gm_users << u
end

# Delete old generic GM users after reassigning their games
['gm1@counterspell.games', 'gm2@counterspell.games', 'gm3@counterspell.games'].each do |email|
  old_gm = User.find_by(email: email)
  if old_gm
    # Reassign any games to a random muppet GM
    old_gm.games_as_gm.update_all(gm_id: gm_users.sample.id) if old_gm.games_as_gm.any?
    old_gm.destroy
  end
end

# Delete old generic player users
User.where("email LIKE ?", "player%@counterspell.games").destroy_all

# Create player users - mostly muppets, some LOTR characters
player_data = [
  { email: "piggy@counterspell.games", name: "Miss Piggy", bio: "<p>Prefers playing charismatic leaders and royalty. Has a collection of 47 character portraits commissioned from professional artists.</p>" },
  { email: "animal@counterspell.games", name: "Animal", bio: "<p>DRUMS! DRUMS! Also enjoys playing barbarians. Very enthusiastic player, sometimes <em>too</em> enthusiastic during combat rounds.</p>" },
  { email: "sam@counterspell.games", name: "Samwise", bio: "<p>Loyal friend and reliable player who never misses a session. Usually plays support characters. Brings snacks for the whole table.</p>" },
  { email: "rizzo@counterspell.games", name: "Rizzo", bio: "<p>Plays rogues exclusively. Has an encyclopedic knowledge of the rulebooks and loves finding creative solutions to problems.</p>" },
  { email: "legolas@counterspell.games", name: "Legolas", bio: "<p>Ranger enthusiast with a preference for archery-focused builds. Known for describing attacks in cinematic detail.</p>" },
  { email: "rowlf@counterspell.games", name: "Rowlf", bio: "<p>Laid-back player who enjoys roleplay over combat. Often plays bards and brings a melodica to the table for \"authentic\" performances.</p>" },
  { email: "beaker@counterspell.games", name: "Beaker", bio: "<p>Meep meep! Loves playing artificers and wizards. Has experienced more character deaths than anyone else at the table, usually from experiments gone wrong.</p>" },
  { email: "gimli@counterspell.games", name: "Gimli", bio: "<p>Dwarf fighter main. Keeps detailed notes of every session and maintains the party's inventory spreadsheet. Competitive but good-natured.</p>" },
  { email: "scooter@counterspell.games", name: "Scooter", bio: "<p>Enthusiastic newcomer to tabletop gaming. Asks lots of questions and takes extensive notes. Currently playing their first campaign.</p>" },
  { email: "swedish@counterspell.games", name: "Swedish Chef", bio: "<p>Börk börk börk! Plays clerics and druids with cooking-themed abilities. Brings themed snacks matching the campaign setting to each session.</p>" },
  { email: "statler@counterspell.games", name: "Statler", bio: "<p>Veteran player with decades of experience. Provides running commentary on game mechanics and rules interpretations. Secretly enjoys every session despite the grumbling.</p>" },
  { email: "waldorf@counterspell.games", name: "Waldorf", bio: "<p>Always plays alongside Statler. Known for witty banter and surprisingly creative problem-solving. Makes the best character backstories at the table.</p>" },
  { email: "fozzie-player@counterspell.games", name: "Fozzie Bear", bio: "<p>Not to be confused with GM Fozzie! This Fozzie is a player who loves comedy-relief characters. Every character has a catchphrase and tells terrible jokes.</p>" },
  { email: "gonzo-player@counterspell.games", name: "Gonzo the Great", bio: "<p>Plays the most outrageous character concepts. Current character: a chicken-riding halfling daredevil. Always looking for the next impossible stunt.</p>" },
  { email: "pepe@counterspell.games", name: "Pepe", bio: "<p>Smooth-talking player who specializes in face characters. Master of persuasion checks and social encounters. Can talk the party out of (or into) anything.</p>" },
  { email: "camilla@counterspell.games", name: "Camilla", bio: "<p>Veteran player who brings intensity and drama to every session. Known for elaborate character voices and memorable roleplay moments. Bawk!</p>" },
  { email: "bunsen@counterspell.games", name: "Dr. Bunsen", bio: "<p>Scientific approach to character building. Extensively researches optimal builds and strategies. Often experiments with unusual multiclass combinations.</p>" }
]

player_users = []
player_data.each do |player|
  u = User.find_or_create_by(email: player[:email]) do |user|
    user.display_name = player[:name]
  end
  u.update!(bio: player[:bio])
  player_users << u
end

# Add games and seats to events
Event.find_each do |event|
  # Skip creating games for cancelled events or if they already have games
  next if event.cancelled? || event.games.any?

  # Most events have 3 tables, some have 1-2
  game_count = [3, 3, 3, 3, 2, 1].sample

  # Don't exceed number of available GMs
  game_count = [game_count, gm_users.count].min

  # Track which GMs are already assigned to this event
  available_gms = gm_users.dup

  game_count.times do |game_index|
    # Pick a GM that hasn't been assigned to this event yet
    gm = available_gms.sample
    available_gms.delete(gm)

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

# Create Heroes
heroes_data = [
  {
    name: "Carina Croftblade",
    pronouns: "She/Her",
    role: "fighter",
    traits: ["Freynor", "Seraph / Divine Wielder", "Highborne"],
    backstory: "Royarch Carina Croftblade, eldest warrior princess of the ruling Rukon Frey family, was somehow sent 2,000 years into the future during a great battle. As much as she exudes royal mannerisms and inherent leadership, strangers have a hard time believing her true origins. She's so far been unsuccessful in proving her lineage and taking her rightful place on the throne. Is she ready to navigate an unfamiliar future to reclaim her purpose in a world that has moved on?"
  },
  {
    name: "Cricket",
    pronouns: "They/Them",
    role: "protector",
    traits: ["Ornath", "Guardian / Stalwart", "Orderborne"],
    backstory: "Cricket is a sentient suit of armor contruct, who speaks and moves with robot-like precision. They were originally charged with protecting the capital city of a mediterranean-esque island, where they spent many happy years with a close-knit team of guards. Cricket's reward for 10 years of loyal service is a sabbatical to better understand the world, learn about new cultures, and catalog various societal norms. They are intensely curious about how things work, why things are, and protecting others from harm."
  },
  {
    name: "Garrick Ironheart",
    pronouns: "He/Him",
    role: "fighter",
    traits: ["Vark", "Warrior / Call of the Brave", "Seaborne"],
    backstory: "Garrick Ironheart may be short in stature, but his ingenious battle mentality, and innovative ideas, make an outsized impact on the world around him. Garrick descends from a noble line of Varks, a proud and mighty people, who were scattered from their mountain home into either lowland or seabound societies around 2,000 years ago. As a representative of the seabound society, The Undertide Dominion, Garrick has volunteered to explore the surface world, bringing back knowledge to improve his people's lives under the ocean."
  },
  {
    name: "Tya Sharkbreaker",
    pronouns: "He/Him",
    role: "protector",
    traits: ["Vark", "Warrior / Call of the Slayer", "Seaborne"],
    backstory: "Growing up on the icy and remote island of Torvryn, Tya Sharkbreaker just wanted to be like his father and brother, lifelong fishermen who proved their worth with a day's catch. But when a then-childhood Tya's scheme to prove himself cost his father's life to save him, things were never the same. Driven by a need to prove his father's final sacrifice was worth his life, Tya now roams the seas, taking on the world's most dangerous jobs just to erase the memories of that fateful day."
  },
  {
    name: "Uliana \"Uli\" Gryphenor",
    pronouns: "She/Her",
    role: "strategist",
    traits: ["Calderaan", "Wizard / School of Knowledge", "Loreborne"],
    backstory: "Uliana \"Uli\" Gryphenor led a quiet life once. She and her partner ran a cozy bookshop in Vire, a progressive and well-kept city off the coast, for many happy years. But when her partner was mysteriously murdered over an ancient missing book, Uli was jolted her from a quiet, semi-retired life, and began a journey of self-taught wizardry. Today, Uli roams the world searching for clues as to her partner's murderer, knowing time is always of the essence."
  },
  {
    name: "Maz Minrah",
    pronouns: "They/Them",
    role: "strategist",
    traits: ["Vark", "Bard / Troubadour", "Orderborne"],
    backstory: "Maz Minrah is a descendant of a long family line of high-achieving healers, who always play by the rules. Maz's academic prowess has recently paid off, as they have accepted membership of the most prestigious guild upholding the ideals of healing through music and magic, The Dancing Gale. Maz feels ready to take on today's toughest challenges, but is slowly finding out that acing a test doesn't always translate into success in the real world."
  },
  {
    name: "Orion Tyrosson",
    pronouns: "He/Him",
    role: "fighter",
    traits: ["Freynor", "Ranger / Beastbound", "Wildborne"],
    backstory: "Orion Tyrosson is a ranger from the small village of Widemeadow. Founded by \"Landers,\" individuals who deepy mistrust magic users, Widemeadow's inhabitants are extremely tight-knit and self-reliant. But when a devastating curse hits the village's water supply, Orion begins an arduous journey to seek help. Little does he know, the very thing he refuses to embrace may be exactly what he needs to survive."
  },
  {
    name: "Jackie Greaves",
    pronouns: "She/Her",
    role: "wild_card",
    traits: ["Vark", "Sorcerer / Elemental Origin", "Wanderborne"],
    backstory: "Jackie Greaves is a Vark, a people who were famously and tragically scattered from their mountain home around 2,000 years ago. But unlike other Varks, who proudly recall where their families settled in the years since, Jackie cannot. For her bubbly and dreamy personality covers amnesia – a deep uncertainty of who she is, and why she sees the concept of death as more fascinating than frightening. But despite this mystery, Jackie's inherent powers make her a strong healer and brave fighter in the battles to come."
  },
  {
    name: "Elisia Moonflower",
    pronouns: "She/Her",
    role: "strategist",
    traits: ["Freynor", "Druid / Warden of Renewal", "Wildborne"],
    backstory: "Elisia Moonflower was found and raised in the forest under the care of a group of wandering druids called \"The Moon Covenant.\" Through them, she learned a unique brand of riftweaving magic, built from honoring the passage of time on the planet's three moons. But the druids' teachings came with a warning: an ancient prophesy foretelling that Elisia should hide away from the world in order to save the world from a disastrous fate. Little did they know, Elisia has a rebellious streak."
  },
  {
    name: "Warp Rigbee",
    pronouns: "He/Him",
    role: "strategist",
    traits: ["Calderaan", "Sorcerer / Primal Origin", "Highborne"],
    backstory: "Warp Rigbee, a cheeky and witty fellow from a rather serious family, just wanted to bring a little joy into his stuffy life. For years, he would shed his family name, and sneak into the city in disguise as a street magician, just to entertain passers by. With plenty of money to his name, Warp desired the best of both worlds: the ability to maintain his familial standing, while also becoming a famous performer fit for the Royarchs themselves. But when his parents found out and cut him off without a penny, Warp is beginning to understand just how difficult life on the street can be."
  },
  {
    name: "Denn",
    pronouns: "He/Him",
    role: "wild_card",
    traits: ["Kiplin", "Rogue / Syndicate", "Slyborne"],
    backstory: "Denn is a Kiplin, an ancestry that resembles a humanoid opossum, complete with a prehensile tail. He uses a combination of nimble dexterity and street smarts to survive in world's largest city, Chellesot. As an orphan, Denn is most loyal to his found family, and lacks the typical Kiplin mannerisms of truth-telling in favor of a scrappy, means-to-an-end mentality. While he would never admit it, Denn yearns for a deeper understanding of his native Kiplin family, a connection he has never known."
  },
  {
    name: "Stacey Batton",
    pronouns: "She/Her",
    role: "fighter",
    traits: ["Caldeynor", "Warrior / Call of the Brave", "Orderborne"],
    backstory: "Stacey Batton's life has been a series of unfortunate events. First her parents separated, leaving her in the care of her mother, who soon after, tragically passed. And while her father tried his best, moving her to the biggest city on the planet, Chellesot, where they set up a successful blacksmithing business, Stacey couldn't help but feel disconnected and lonely from those around her. But when her father suddenly went missing, leaving behind a cryptic message, she's forced to rediscover her long-lost dreams of traveling the universe."
  },
  {
    name: "Raanmaar",
    pronouns: "He/Him",
    role: "strategist",
    traits: ["Rax", "Druid / Warden of the Elements", "Wildborne"],
    backstory: "Raanmaar is a traveling druidic herbalist and gardener, from the distant moon of Rax, a place far wilder and stranger than your imagination. A peace-loving individual who bears a resemblance to a giant ram, Raanmaar belies his intimidating looks with a deep, soft-spoken voice of great power. By day, Raanmaar's magical poetry and song breathes life into the natural world, while by night, his recurring prophetic dreams of preventing a great cataclysm keep him wide awake."
  },
  {
    name: "Inara Darkstar",
    pronouns: "She/Her",
    role: "wild_card",
    traits: ["Freynor", "Wizard / School of War", "Orderborne"],
    backstory: "Inara Darkstar had it all, once. A comfortable home, an honored family name that preceded her, and privilege that granted her access to the best schools. Inara had happily accepted a place among The Dancing Gale guild, a prestigious group of bards who heal the world with music. But when she found out her family's success was only made possible through a powerful crime group, the Machine Syndicate, she gave up her guildship to seek revenge for her family's honor."
  },
  {
    name: "Meechi Sirans",
    pronouns: "They/Them",
    role: "strategist",
    traits: ["Merivian", "Ranger / Wayfinder", "Seaborne"],
    backstory: "Meechi Sirans, a daring Merivian navigator from the underwater capital of Raelinith Thal, \"borrowed\" a special Terrasuit meant only for testing and never gave it back. Now living on land, this quick-witted, seahorse-like riftweaver uses their natural gift for navigation and charm to guide airships and explorers across the world's hidden leylines while quietly fearing the day someone demands the suit's, and their own, return under the ocean. Restless, ingenious, and impossible to pin down, Meechi has found a new world above the water and isn't able to go back anytime soon."
  }
]

heroes_data.each do |hero_data|
  hero = Hero.find_or_initialize_by(name: hero_data[:name])

  hero.pronouns = hero_data[:pronouns]
  hero.role = hero_data[:role]

  # Find and assign traits
  hero_traits = hero_data[:traits].map do |trait_name|
    Trait.find_by(name: trait_name)
  end.compact

  hero.traits = hero_traits
  hero.save!

  # Set rich_text fields after saving (ActionText requires persisted record)
  # Wrap backstory in HTML paragraph tags for proper rich text formatting
  hero.update!(
    backstory: "<p>#{hero_data[:backstory]}</p>",
    summary: "<p><strong>#{hero_traits[0]&.name}</strong> #{hero.role.humanize.downcase} with a mysterious past and unwavering determination.</p>"
  )

  puts "Created/Updated hero: #{hero.name}"
end

# Assign heroes to ALL seats (all events, not just past/upcoming)
Event.find_each do |event|
  event.games.each do |game|
    # First, ensure ALL seats have heroes (even empty seats)
    game.seats.where(hero_id: nil).each do |seat|
      available_heroes = Hero.where.not(id: game.seats.where.not(hero_id: nil).pluck(:hero_id))
      if available_heroes.any?
        seat.update!(hero: available_heroes.sample)
      else
        # If we've run out of unique heroes for this game, just pick any hero
        seat.update!(hero: Hero.all.sample)
      end
    end
  end
end

# Fill seats with players for past and upcoming events
Event.where(status: [:past, :upcoming]).find_each do |event|
  event.games.each do |game|
    empty_seats = game.seats.where(user_id: nil).to_a
    next if empty_seats.empty?

    # Get players NOT already at this event (either as a player OR as a GM)
    assigned_player_ids = event.games.joins(:seats).where.not(seats: { user_id: nil }).pluck('seats.user_id').uniq
    gm_ids_at_event = event.games.pluck(:gm_id).uniq
    excluded_user_ids = assigned_player_ids + gm_ids_at_event
    available_players = player_users.reject { |p| excluded_user_ids.include?(p.id) }

    # For past events: fill ALL seats
    # For upcoming events: leave 1-2 seats empty per game
    if event.past?
      seats_to_fill = empty_seats.count
    else
      # Upcoming: leave some seats available (1-2 per game)
      seats_to_fill = [empty_seats.count - [1, 2].sample, 0].max
    end

    # Fill as many seats as we can with available players
    filled = 0
    empty_seats.shuffle.each do |seat|
      break if filled >= seats_to_fill
      break if available_players.empty?

      player = available_players.shift
      seat.update!(user: player)
      filled += 1
    end
  end
end
