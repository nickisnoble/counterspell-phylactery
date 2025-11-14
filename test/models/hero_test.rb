require "test_helper"

class HeroTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "requires certain traits" do
    hero = Hero.new(name: "Test Hero", pronouns: "They/Them", role: "fighter", user: @user)
    assert_not hero.valid?
    assert_includes hero.errors.full_messages.join, "must include"
  end

  test "prevents duplicate traits of same type" do
    ancestry1 = Trait.create!(type: "ANCESTRY", name: "Ancestry 1")
    ancestry2 = Trait.create!(type: "ANCESTRY", name: "Ancestry 2")
    background = Trait.create!(type: "BACKGROUND", name: "Background")
    class_trait = Trait.create!(type: "CLASS", name: "Class Trait")

    hero = Hero.new(
      name: "Test Hero",
      role: "fighter",
      user: @user,
      traits: [ancestry1, ancestry2, background, class_trait]
    )
    assert_not hero.valid?
    assert_includes hero.errors.full_messages.join, "duplicate"
  end

  test "allows one of each required trait type" do
    ancestry = Trait.create!(type: "ANCESTRY", name: "Ancestry")
    background = Trait.create!(type: "BACKGROUND", name: "Background")
    class_trait = Trait.create!(type: "CLASS", name: "Class Trait")

    hero = Hero.new(
      name: "Valid Hero",
      role: "fighter",
      user: @user,
      traits: [ancestry, background, class_trait]
    )
    assert hero.valid?
  end

  test "generates slug from name" do
    ancestry = Trait.create!(type: "ANCESTRY", name: "Ancestry")
    background = Trait.create!(type: "BACKGROUND", name: "Background")
    class_trait = Trait.create!(type: "CLASS", name: "Class Trait")

    hero = Hero.create!(
      name: "Test Hero Name",
      role: "fighter",
      user: @user,
      traits: [ancestry, background, class_trait]
    )
    assert_equal "test-hero-name", hero.slug
  end

  test "requires name" do
    hero = Hero.new(role: "fighter", user: @user)
    assert_not hero.valid?
  end

  test "validates name uniqueness case-insensitively" do
    ancestry = Trait.create!(type: "ANCESTRY", name: "Ancestry")
    background = Trait.create!(type: "BACKGROUND", name: "Background")
    class_trait = Trait.create!(type: "CLASS", name: "Class Trait")

    Hero.create!(
      name: "Unique Hero",
      role: "fighter",
      user: @user,
      traits: [ancestry, background, class_trait]
    )

    duplicate = Hero.new(
      name: "unique hero",
      role: "fighter",
      user: @user,
      traits: [ancestry, background, class_trait]
    )
    assert_not duplicate.valid?
  end

  test "normalizes ideal and flaw by stripping whitespace" do
    ancestry = Trait.create!(type: "ANCESTRY", name: "Ancestry For Normalization Test")
    background = Trait.create!(type: "BACKGROUND", name: "Background For Normalization Test")
    class_trait = Trait.create!(type: "CLASS", name: "Class For Normalization Test")

    hero = Hero.create!(
      name: "Hero With Whitespace Fields",
      role: "fighter",
      user: @user,
      ideal: "  Justice  ",
      flaw: "  Stubborn  ",
      traits: [ancestry, background, class_trait]
    )

    assert_equal "Justice", hero.ideal
    assert_equal "Stubborn", hero.flaw
  end

  test "validates role enum" do
    ancestry = Trait.create!(type: "ANCESTRY", name: "Ancestry")
    background = Trait.create!(type: "BACKGROUND", name: "Background")
    class_trait = Trait.create!(type: "CLASS", name: "Class Trait")

    hero = Hero.new(
      name: "Test Hero",
      role: "invalid_role",
      user: @user,
      traits: [ancestry, background, class_trait]
    )
    assert_not hero.valid?
  end
end
