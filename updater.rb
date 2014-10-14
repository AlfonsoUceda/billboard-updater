require 'rubygems'
require 'bundler/setup'
require 'mongoid'
require 'billboard-spanish'

Dir["models/concerns/*.rb"].each { |file| require_relative file }
Dir["models/*.rb"].each { |file| require_relative file }

I18n.enforce_available_locales = false

Mongoid.load!('config/mongoid.yml', :development)
Mongoid::Tasks::Database.create_indexes

class Updater
  attr_accessor :crawler

  def initialize(crawler_name)
    self.crawler = crawler_name
  end

  def insert_provinces
    p 'INSERTING PROVINCES'
    provinces = crawler.provinces
    provinces.each do |province|
      Province.create province
    end
    p "Province size: #{Province.count}"
    p '-----------------------------------'
  end

  def insert_cities
    p 'INSERTING CITIES'
    Province.all.each_with_index do |province, index|
      cities = crawler.cities(province.url)
      cities.each do |city|
        province.cities.create city
      end
    end
    p "City size: #{City.count}"
    p '-----------------------------------'
  end

  def insert_cinemas
    p 'INSERTING CINEMAS'
    City.all.each_with_index do |city, index|
      cinemas = crawler.cinemas(city.url)
      cinemas.each do |hash_cinema|
        cinema = city.cinemas.find_or_initialize_by name: hash_cinema[:name]
        if cinema.new_record?
          cinema.url = hash_cinema[:url]
          cinema.save
        end
      end
    end
    p "Cinema size: #{Cinema.count}"
    p '-----------------------------------'
  end

  def insert_films
    p 'INSERTING FILMS'
    Cinema.all.each_with_index do |cinema, index|
      proyection_dates = crawler.films(cinema.url)
      proyection_dates.each do |proyection_date, films|
        films.each do |film|
          hours = film.delete :hours
          film_saved = cinema.films.find_or_create_by film
          hours.each do |hour|
            schedule = film_saved.schedules.create proyected_at: DateTime.parse("#{proyection_date} #{hour}")
          end
        end
      end
      p "FILMS FOR CINEMA #{cinema.name} INSERTED"
    end
    p '-----------------------------------'
  end

  private

  def crawler=(name)
    @crawler = Object.const_get("Billboard::Crawlers::#{name.to_s.capitalize}").new
  end
end

updater = Updater.new :ecartelera

# Cinema.destroy_all
# City.destroy_all
# Province.destroy_all

# updater.insert_provinces
# updater.insert_cities
updater.insert_cinemas
updater.insert_films
