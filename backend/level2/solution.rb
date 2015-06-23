require 'json'
require 'date'

class Car
	attr_accessor :id, :price_per_km, :price_per_day
	@@cars = []
	def initialize(car)
		@id = car[:id]
		@price_per_km = car[:price_per_km]
		@price_per_day = car[:price_per_day]
		@@cars << self
	end

	def self.find(id)
		@@cars.each do |car|
			return car if car.id == id
		end
		return nil
	end
end

class Rental
	attr_accessor :id, :price
	@@rentals = []
	def initialize (rental)
		@id = rental[:id]
		@car = Car.find(rental[:car_id])
		@start_date = rental[:start_date]
		@end_date = rental[:end_date]
		@distance = rental[:distance]
		@price = get_price
		@@rentals << self
	end

	def get_price
		begin
			days = Date.parse(@end_date).mjd - Date.parse(@start_date).mjd + 1
			price = @car.price_per_km * @distance
			price_per_day = @car.price_per_day
			rest_of_days = days
			if days >= 1
				price += price_per_day * 1
				rest_of_days -= 1
			end
			if days >= 4
				price += price_per_day * 0.9 * 3
				rest_of_days -= 3
			else 
				price += price_per_day * 0.9 * rest_of_days
			end
			if days >= 10
				price += price_per_day * 0.7 * 6 + price_per_day * 0.5 * (days-10)
				rest_of_days -= 6
			else
				price += price_per_day * 0.7 * rest_of_days
			end
			price.to_i	
		rescue
			'error'
		end
	end

	def self.to_json
		_hash = {rentals: []}
		@@rentals.each do |rental|
			_hash[:rentals] << {id: rental.id, price: rental.price}
		end
		JSON.pretty_generate(_hash)
	end
end

data = JSON.parse(open("data.json").read, symbolize_names: true)
data[:cars].each do |car|
	Car.new(car)
end
data[:rentals].each do |rental|
	Rental.new(rental)
end
puts Rental.to_json
