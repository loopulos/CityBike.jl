using Requests

key = "AIzaSyCXia5c3mcH4rxdFtLl6qOew0g_W5qOGrE"

# lat, long
origin = "19.42661,-99.14447"

destination = "19.36065%2C-99.168669"

origin = "19.373262%2C-99.184333"
destination = "19.371152%2C-99.183034"

mode = "driving"
traffic_model = "best_guess"
transit_mode = "subway"

URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$(origin)&destinations=$(destination)&mode=$(mode)&key=$(key)"

URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$(origin)&destinations=$(destination)&mode=$(mode)&transit_mode=$(transit_mode)&key=$(key)"

println(URL)

response = Requests.json(get(URL))

response["rows"][1]["elements"][1]["duration"]["value"]

response["rows"][1]["elements"]
