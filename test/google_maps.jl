using Requests
key = "AIzaSyCXia5c3mcH4rxdFtLl6qOew0g_W5qOGrE"
# lat, long
mode = ["driving", "bicycling", "transit"]
#traffic_model = "best_guess"
#transit_mode = "subway"
estaciones = float64([readcsv("estacionesn.csv")[2:end,1] readcsv("estacionesn.csv")[2:end,10:11]])
ns = size(estaciones)[1]
ns = 5
nt = int(ns * (ns - 1)/2)
durs = zeros(int(ns * (ns - 1) / 2),8)
s=1
for j = 1:(ns-1)
    for k = (j+1):ns
        origin = string(estaciones[j,2],",",estaciones[j,3])
        destination = string(estaciones[k,2],"%2C",estaciones[k,3])
        durs[s,1] = estaciones[j,1]; durs[s,2] = estaciones[k,1]
        for i = 0:(length(mode)-1)
            #println(j,'\t',k,'\t',i)
            URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$(origin)&destinations=$(destination)&mode=$(mode[i])&key=$(key)"

            response = Requests.json(get(URL))
            durs[s,2 + 2*i+1] = response["rows"][1]["elements"][1]["duration"]["value"]
            durs[s,2 + 2*i+1] = response["rows"][1]["elements"][1]["distance"]["value"]
        end
        s += 1
    end
end
durs
URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=19.426611,-99.14447&destinations=19.389477%2C-99.157513&mode=driving&key=$(key)"
Requests.json(get(URL))
