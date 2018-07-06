class PlayerValidator < ActiveModel::Validator
  
  def validate record
    if record.is_ai
      if !record.ai_type
        record.errors.add :ai_type, "must been defined when if is ai"
      end
    end
  end

end

class Player < Ohm::Model

  include ActiveModel::Validations

  DEFAULT_COLOR = -1
  NEUTRAL_COLOR = 0

  collection :planets, :Planet
  collection :fleets, :Fleet
  reference :game, :Game

  attribute :is_admin 
  attribute :name
  attribute :color_id, lambda { |x| x.to_i }
  attribute :is_ai
  attribute :ai_type

  validates_with PlayerValidator
  validates :name, presence: true, length: { in: 1..32 }
  validates :color_id, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: -1 }
  validates :is_admin, inclusion: { in: [true, false] }
  validates :is_ai, inclusion: { in: [true, false] }
  validates :ai_type, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def has_fleets_or_planets
    self.planets.size > 0 or self.fleets.size > 0
  end

    def update hash
    obj = Player.new hash
    if obj.valid?
      super hash
      true
    else
      false
    end
  end

  def self.create hash
    obj = Player.new hash
    if obj.valid?
      super hash
      true
    else
      false
    end
  end

  def save
    if self.valid?
      super
      true
    else
      false
    end
  end

end