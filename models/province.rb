class Province
  include Mongoid::Document
  include Mongoid::Timestamps
  include ::Sluggable

  field :name, type: String
  field :url,  type: String

  has_many :cities
end
