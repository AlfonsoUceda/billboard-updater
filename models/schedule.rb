class Schedule
  include Mongoid::Document
  include Mongoid::Timestamps

  field :proyected_at, type: DateTime

  embedded_in :film, inverse_of: :schedules
end