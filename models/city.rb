class City
  include Mongoid::Document
  include Mongoid::Timestamps
  include ::Sluggable

  field :name, type: String
  field :url,  type: String

  belongs_to :province
  has_many :cinemas
end