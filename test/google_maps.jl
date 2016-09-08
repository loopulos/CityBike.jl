using Requests
key = "AIzaSyCXia5c3mcH4rxdFtLl6qOew0g_W5qOGrE"
key2 = "AIzaSyDrhZkvOxrJkyCYwr17i7evXod8LCF1AEo"
estaciones = float64([readcsv("estacionesn.csv")[2:end,1] readcsv("estacionesn.csv")[2:end,10:11]])
# lat, long
#traffic_model = "best_guess"
#transit_mode = "subway"
function manda(args::Array{Int64,1},mode::Array{ASCIIString,1},origin::AbstractString,destination::AbstractString,key::AbstractString, durs::Array{Float64,2})
    l,sb = args
    for i = 0:(length(mode)-1) #se realizan los requests en los 3 modos

        URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$(origin)&destinations=$(destination)&mode=$(mode[i+1])&key=$(key)"
        response = Requests.json(get(URL))
        produce("recibido")
        sleep(5)
        println(l,'\t',mode[i+1],'\t',response["status"])
        for k = 1:sb #este es para almacenar cada uno de los sb request que se enviaron
            durs[l*sb+k,2 + 2*i+1] = response["rows"][1]["elements"][k]["distance"]["value"]
            durs[l*sb+k,2 + 2*i+2] = response["rows"][1]["elements"][k]["duration"]["value"]
        end
    end
end
######################ESTA ES LA SECCION DE PRUEBA ########################################################################################################
# origin = string(estaciones[1,2],",",estaciones[1,3])
# destination = string(estaciones[11,2],"%2C",estaciones[11,3])
# for i = 2:50
#       #origin = origin*string("|",estaciones[i,2],",",estaciones[i,3])
#    destination = destination*string("%7C",estaciones[i,2],"%2C",estaciones[i,3])
# end
# URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$(origin)&destinations=$(destination)&mode=transit&key=$(key2)"
# response = Requests.json(get(URL))
# response["rows"][1]["elements"][100]["distance"]["value"]
#####################################################AQUI EMPIEZA #############################################################

usos = int(readcsv("usofilt2_2015.csv"))#el uso de estaciones filtrado
ns = 452 #numero de estaciones que hay
durs = Array(Array{Float64,2},ns)  #es el arreglo de salida
mode = ["driving", "bicycling", "transit"] #los modos que hay para hacer el request
sb = 100 #tamanio del bloque

for j = 1:ns
    mat = usos[usos[:,1].==j,:] #trabaja sobre el indice j de los datos,
    nit = divrem(size(mat)[1], sb) #se obtiene cuantas iteraciones de 100 y el sobrante para hacer el request
    lat1 = estaciones[estaciones[:,1].==j,:][2]; long1 = estaciones[estaciones[:,1].==j,:][3] #aqui se define la estacion de inicio (coordenadas)
    origin = string(lat1,",",long1)
    durs[j] = zeros(size(mat)[1], 8)
    println("Voy con la estacion ", j)
    for l = 0:(nit[1]-1) #aqui se van a construir los bloques para los requests
        lat2 = estaciones[estaciones[:,1].==mat[l*sb+1,2],:][2]; long2 = estaciones[estaciones[:,1].==mat[l*sb+1,2],:][3]
        destination = string(lat2,"%2C",long2); durs[j][1,1] = mat[1,1]; durs[j][1,2] = mat[1,2]
        #Aqui se concatenan las de llegada restantes (100 max)
        for i = 2:sb
            destination = destination*string("%7C",estaciones[estaciones[:,1].==mat[l*sb+i,2],:][2],"%2C",estaciones[estaciones[:,1].==mat[l*sb+i,2],:][3])
            durs[j][l*sb+i,1] = mat[l*sb+i,1]; durs[j][l*sb+i,2] = mat[l*sb+i,2]
        end
        args = [l,sb]
        taskQ = Task(() -> manda(args,mode,origin,destination,key2,durs[j]))
        for x in taskQ
        end

    end
    #falta enviar el request faltante (sobrante de n/sb)

    lat2 = estaciones[estaciones[:,1].==mat[nit[1]*sb+1,2],:][2]; long2 =estaciones[estaciones[:,1].==mat[nit[1]*sb+1,2],:][3]
    destination = string(lat2,"%2C",long2)
    for i = 2:nit[2]
        destination = destination*string("%7C",estaciones[estaciones[:,1].==mat[nit[1]*sb+i,2],:][2],"%2C",estaciones[estaciones[:,1].==mat[nit[1]*sb+i,2],:][3])
        durs[j][nit[1]*sb+i,1] = mat[nit[1]*sb+i,1]; durs[j][nit[1]*sb+i,2] = mat[nit[1]*sb+i,2]
    end
    args = [nit[1],nit[2]]
    taskQ = Task(() -> manda(args,mode,origin,destination,key2,durs[j]))
    for x in taskQ
    end
end
##################
# a = durs[2]
# a[a[:,1].==2.0,:]
