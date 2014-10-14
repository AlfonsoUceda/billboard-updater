class Province
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :url,  type: String

  has_many :cities
end