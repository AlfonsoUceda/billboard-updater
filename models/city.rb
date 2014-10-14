class City
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :url,  type: String

  belongs_to :province
  has_many :cinemas
end