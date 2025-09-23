json.extract! hero, :id, :name, :pronouns, :category, :role_id, :ancestry_id, :created_at, :updated_at
json.url hero_url(hero, format: :json)
