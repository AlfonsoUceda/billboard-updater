class Cinema
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :url,  type: String

  belongs_to :city
  embeds_many :films
end