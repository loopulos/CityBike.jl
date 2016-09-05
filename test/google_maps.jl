using Requests
key = "AIzaSyCXia5c3mcH4rxdFtLl6qOew0g_W5qOGrE"
# lat, long
mode = ["driving", "bicycling", "transit"]
#traffic_model = "best_guess"
#transit_mode = "subway"
#URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$(origin)&destinations=$(destination)&mode=bicycling&key=$(key)"
#response = Requests.json(get(URL))
# response["rows"][1]["elements"][1]["distance"]["value"]
estaciones = float64([readcsv("estacionesn.csv")[2:end,1] readcsv("estacionesn.csv")[2:end,10:11]])
usos = int(readcsv("uso2015.csv"))
usos = usos[usos[:,1].<1000,:]; usos = usos[usos[:,2].<1000,:] #se eliminan todas las estaciones mayores 1000

ns = int(trunc(size(usos)[1] / 10))
durs = zeros(size(usos)[1],8)
s = 0

for j = 1:ns
    #se definen las lat y long con las que se empiezan,
    lat1 = estaciones[estaciones[:,1].==usos[j*s+1,1],:][2]; long1 = estaciones[estaciones[:,1].==usos[j*s+1,1],:][3]
    origin = string(lat1,",",long1)
    lat2 = estaciones[estaciones[:,1].==usos[j*s+1,2],:][2]; long2 = estaciones[estaciones[:,1].==usos[j*s+1,2],:][3]
    destination = string(lat2,"%2C",long2)
    #Aqui se concatenan las restantes (10 max)
#HASTA AQUI VOY FALTA ARREGLAR LO QUE SIGUE ############################
    for i = (j*s+2):(10*j + 10)
        origin = origin*string("|",usos[i,1],",",usos[i,1])
        destination = destination*string("%7C",usos[i,2],"%2C",usos[i,2])
    end


    durs[s,1] = usos[j,1]; durs[s,2] = usos[k,1]
    for i = 0:(length(mode)-1)
        #println(j,'\t',k,'\t',i)
        URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$(origin)&destinations=$(destination)&mode=$(mode[i+1])&key=$(key)"
        response = Requests.json(get(URL))
        durs[s,2 + 2*i+1] = response["rows"][1]["elements"][1]["distance"]["value"]
        durs[s,2 + 2*i+2] = response["rows"][1]["elements"][1]["duration"]["value"]
    end
end
durs
origin = string(estaciones[1,2],",",estaciones[1,3])
destination = string(estaciones[11,2],"%2C",estaciones[11,3])
for i = 2:10
    origin = origin*string("|",estaciones[i,2],",",estaciones[i,3])
    destination = destination*string("%7C",estaciones[i+10,2],"%2C",estaciones[i+10,3])
end
