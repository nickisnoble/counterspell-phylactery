require "test_helper"

class TraitTest < ActiveSupport::TestCase
  test "normalizes type to uppercase" do
    trait = Trait.create!(type: "ancestry", name: "Test Trait")
    assert_equal "ANCESTRY", trait.type
  end

  test "validates type is alphanumeric" do
    trait = Trait.new(type: "test-123!", name: "Test")
    assert_not trait.valid?
  end

  test "requires type" do
    trait = Trait.new(name: "Test")
    assert_not trait.valid?
    assert_includes trait.errors[:type], "can't be blank"
  end

  test "requires name" do
    trait = Trait.new(type: "ANCESTRY")
    assert_not trait.valid?
  end

  test "validates name uniqueness case-insensitively" do
    Trait.create!(type: "ANCESTRY", name: "Unique Name")
    duplicate = Trait.new(type: "ANCESTRY", name: "unique name")
    assert_not duplicate.valid?
  end

  test "abilities defaults to empty hash" do
    trait = Trait.create!(type: "ANCESTRY", name: "Test")
    assert_equal({}, trait.abilities)
  end

  test "serializes abilities as JSON" do
    abilities = { "Skill" => "Description", "Power" => "Effect" }
    trait = Trait.create!(type: "ANCESTRY", name: "Test", abilities: abilities)
    assert_equal abilities, trait.reload.abilities
  end

  test "generates slug from name" do
    trait = Trait.create!(type: "ANCESTRY", name: "Test Trait Name")
    assert_equal "test-trait-name", trait.slug
  end

  test "slug is unique" do
    Trait.create!(type: "ANCESTRY", name: "Test Trait")
    duplicate = Trait.new(type: "BACKGROUND", name: "Test Trait")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "normalizes description by stripping and squishing whitespace" do
    trait = Trait.create!(type: "ANCESTRY", name: "Test", description: "  Multiple   spaces   here  ")
    assert_equal "Multiple spaces here", trait.description
  end
end
