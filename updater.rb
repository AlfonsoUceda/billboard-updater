require 'rubygems'
require 'bundler/setup'
require 'mongoid'
require 'billboard'

Dir["models/*.rb"].each { |file| require_relative file }

class Updater
  def initialize
    Mongoid.load!('config/mongoid.yml', :development)
  end

  def insert_provinces
    p 'INSERTING PROVINCES'
    provinces = fetcher.provinces
    Province.collection.insert provinces
    p "Province size: #{Province.count}"
    p '-----------------------------------'
  end

  def insert_cities
    p 'INSERTING CITIES'
    Province.all.each_with_index do |province, index|
      cities = fetcher.cities(province.url)
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
      cinemas = fetcher.cinemas(city.url)
      cinemas.each do |cinema|
        city.cinemas.create cinema
      end
    end
    p "Cinema size: #{Cinema.count}"
    p '-----------------------------------'
  end

  def insert_films
    p 'INSERTING FILMS'
    Cinema.all.each_with_index do |cinema, index|
      proyection_dates = fetcher.films(cinema.url)
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
    p "Film size: #{Film.count}"
    p '-----------------------------------'
  end

  private

  def fetcher
    @fetcher ||= Billboard::Fetcher.new
  end
end

# updater = Updater.new
#
# Cinema.destroy_all
# City.destroy_all
# Province.destroy_all
#
# updater.insert_provinces
# updater.insert_cities
# updater.insert_cinemas
# updater.insert_films
