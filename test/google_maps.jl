using Requests

key = "AIzaSyCXia5c3mcH4rxdFtLl6qOew0g_W5qOGrE"

# lat, long
origin = "19.42661,-99.14447"

destination = "19.36065%2C-99.168669"

origin = "19.373262%2C-99.184333"
destination = "19.371152%2C-99.183034"

mode = ["driving", "bicycling", "transit"]
traffic_model = "best_guess"
transit_mode = "subway"

estaciones = readcsv("/Users/martinC3/Google Drive/EcobiciDATA/EcobiciDF/estacionesn.csv")

for i in 1:15
    println(i, estaciones[1, i])
end


durs = zeros(3, )

for i in length(mode):

    URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$(origin)&destinations=$(destination)&mode=$(mode[i])&key=$(key)"

    response = Requests.json(get(URL))
    response["rows"][1]["elements"][1]["duration"]["value"]

end
