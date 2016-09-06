using Requests
key = "AIzaSyCXia5c3mcH4rxdFtLl6qOew0g_W5qOGrE"
key2 = "AIzaSyDPPYMVTpm-utCdroeBHN_K8EmHFsQOpbE"
estaciones = float64([readcsv("estacionesn.csv")[2:end,1] readcsv("estacionesn.csv")[2:end,10:11]])
# lat, long
#traffic_model = "best_guess"
#transit_mode = "subway"

######################ESTA ES LA SECCION DE PRUEBA ########################################################################################################
# origin = string(estaciones[1,2],",",estaciones[1,3])
# destination = string(estaciones[11,2],"%2C",estaciones[11,3])
# for i = 2:100
#     #origin = origin*string("|",estaciones[i,2],",",estaciones[i,3])
#     destination = destination*string("%7C",estaciones[i,2],"%2C",estaciones[i,3])
# end
# URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$(origin)&destinations=$(destination)&mode=transit&key=$(key)"
# response = Requests.json(get(URL))
# response["rows"][1]["elements"][100]["distance"]["value"]
#####################################################AQUI EMPIEZA #############################################################

usos = int(readcsv("usofilt2_2015.csv"))#el uso de estaciones filtrado
ns = 452 #numero de estaciones que hay
durs = Array(Array{Float64,2},ns)  #es el arreglo de salida
mode = ["driving", "bicycling", "transit"] #los modos que hay para hacer el request


for j = 1:ns
    mat = usos[usos[:,1].==j,:] #trabaja sobre el indice j de los datos,
    nit = divrem(size(mat)[1], 100) #se obtiene cuantas iteraciones de 100 y el sobrante para hacer el request
    lat1 = estaciones[estaciones[:,1].==j,:][2]; long1 = estaciones[estaciones[:,1].==j,:][3] #aqui se define la estacion de inicio (coordenadas)
    origin = string(lat1,",",long1)
    durs[j] = zeros(size(mat)[1], 8)

    for l = 0:(nit[1]-1) #aqui se van a construir los bloques para los requests
        lat2 = estaciones[estaciones[:,1].==mat[l*100+1,2],:][2]; long2 = estaciones[estaciones[:,1].==mat[l*100+1,2],:][3]
        destination = string(lat2,"%2C",long2); durs[j][1,1] = mat[1,1]; durs[j][1,2] = mat[1,2]
        #Aqui se concatenan las de llegada restantes (100 max)
        for i = 2:100
            destination = destination*string("%7C",estaciones[estaciones[:,1].==mat[l*100+i,2],:][2],"%2C",estaciones[estaciones[:,1].==mat[l*100+i,2],:][3])
            durs[j][l*100+i,1] = mat[l*100+i,1]; durs[j][l*100+i,2] = mat[l*100+i,2]
        end

        for i = 0:(length(mode)-1) #se realizan los requests en los 3 modos

            URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$(origin)&destinations=$(destination)&mode=$(mode[i+1])&key=$(key)"
            response = Requests.json(get(URL))
            println(j,'\t',l,'\t',mode[i+1],'\t',response["status"])
            for k = 1:100 #este es para almacenar cada uno de los 100 request que se enviaron
                durs[j][l*100+k,2 + 2*i+1] = response["rows"][1]["elements"][k]["distance"]["value"]
                durs[j][l*100+k,2 + 2*i+2] = response["rows"][1]["elements"][k]["duration"]["value"]
            end
        end
    end
    #falta enviar el request faltante (sobrante de n/100)

    lat2 = estaciones[estaciones[:,1].==mat[nit[1]*100+1,2],:][2]; long2 =estaciones[estaciones[:,1].==mat[nit[1]*100+1,2],:][3]
    destination = string(lat2,"%2C",long2)
    for i = 2:nit[2]
        destination = destination*string("%7C",estaciones[estaciones[:,1].==mat[nit[1]*100+i,2],:][2],"%2C",estaciones[estaciones[:,1].==mat[nit[1]*100+i,2],:][3])
        durs[j][nit[1]*100+i,1] = mat[nit[1]*100+i,1]; durs[j][nit[1]*100+i,2] = mat[nit[1]*100+i,2]
    end
    for i = 0:(length(mode)-1) #se realizan los requests en los 3 modos
        #println(j,'\t',k,'\t',i)
        URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$(origin)&destinations=$(destination)&mode=$(mode[i+1])&key=$(key)"
        response = Requests.json(get(URL))
        for k = 1:nit[2] #este es para almacenar cada uno de los 100 request que se enviaron
            durs[nit[1]*100+k,2 + 2*i+1] = response["rows"][1]["elements"][k]["distance"]["value"]
            durs[nit[1]*100+k,2 + 2*i+2] = response["rows"][1]["elements"][k]["duration"]["value"]
        end
    end


end
