require 'active_support'

module Sluggable
  extend ActiveSupport::Concern

  included do
    field :slug, type: String

    before_create :generate_slug

    index({ slug: 1, url: 1 }, { unique: true, name: "slug_url_index" })
  end

  protected

  def generate_slug
    self.slug = self.name.parameterize
  end
end