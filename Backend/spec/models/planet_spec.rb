require "rails_helper"

RSpec.describe Planet, type: :model do
  it "saves with valid props" do
    planet = Planet.new
    planet.set_properties
    valid = planet.valid?
    expect(valid).to be true
  end
  it "not saves with invalid props" do
    planet = Planet.new
    planet.kill_perc = 0
    planet.production = 0
    planet.buff = 0
    valid = planet.valid?
    expect(valid).to be false
  end
  it "makes players planet" do 
    planet_make = Planet.new
    planet_make.make_players_planet
    planet = Planet.new
    planet.production = 10
    planet.kill_perc = 0.4
    planet.ships = 10
    expect(planet == planet_make).to be true
  end
end