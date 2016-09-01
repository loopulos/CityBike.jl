using Requests
key = "AIzaSyCXia5c3mcH4rxdFtLl6qOew0g_W5qOGrE"
# lat, long
mode = ["driving", "bicycling", "transit"]
#traffic_model = "best_guess"
#transit_mode = "subway"
estaciones = float64([readcsv("estacionesn.csv")[2:end,1] readcsv("estacionesn.csv")[2:end,10:11]])
ns = size(estaciones)[1]
durs = zeros(5, int(ns * (ns - 1) / 2))
for j = 1:(ns-1)
  for k = (j+1):ns
    origin = string(estaciones[j,2],",",estaciones[j,3])
    destination = string(estaciones[k,2],"%2C",estaciones[k,3])
    durs[j,1] = estaciones[j,1]; durs[j,2] = estaciones[k,1]
    for i in 1:length(mode)

      URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$(origin)&destinations=$(destination)&mode=$(mode[i])&key=$(key)"

      response = Requests.json(get(URL))
      durs[j,2+i] = response["rows"][1]["elements"][1]["duration"]["value"]

      end
    end
end
