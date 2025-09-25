class Hero::Ancestry < ApplicationRecord
  include Hero::Trait
  
  serialize :abilities, coder: JSON
end
