require 'json'
require 'date'

def get_car(cars,id)
	cars.each do |car|
			return car if car[:id] == id
	end
end

data = JSON.parse(open("data.json").read, symbolize_names: true)
output = {rentals: [] }
data[:rentals].each do |rental|
	car = get_car(data[:cars],rental[:car_id])
	days = Date.parse(rental[:end_date]).mjd - Date.parse(rental[:start_date]).mjd + 1
	#puts days
	price = car[:price_per_day] * days + car[:price_per_km] * rental[:distance]
	output[:rentals] << {id: rental[:id], price: price}
end
puts JSON.pretty_generate(output)
