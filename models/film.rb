class Film
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title,   type: String
  field :length,  type: String
  field :country, type: String
  field :age,     type: String
  field :image,   type: String

  embeds_many :schedules
  embedded_in :cinema, inverse_of: :films
end