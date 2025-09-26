require "test_helper"

class HeroTest < ActiveSupport::TestCase
  test "requires certain traits" do
    hero = Hero.new(name: "Test Hero", pronouns: "They/Them", role: "fighter")
    assert_not hero.valid?
    assert_includes hero.errors.full_messages.join, "must include"
  end
end
