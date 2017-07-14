using Requests
cd("/home/alfredo/Git/CityBike.jl/test")
keys = ["AIzaSyC5Y9Wky2FFpN7mDiV_GdGATLIHNG3czDY","AIzaSyCBZKUNqVU_8-NrMbp_LSoxK37PT-8qV6c","AIzaSyDdYBorbWGaSLeRnqO9yY1tXUshJiX17NI","AIzaSyAmWj_o-AWXNtwQpmjY1sG8R3qTh0E6Wig","AIzaSyBrPRteCYgdRc-ZRTMOmqE0veTmCZ2NuUM","AIzaSyCa-GUJYeae-1JO3-zyM2NbV985QE83w1A","AIzaSyBuQNx3niOUU7_bG3iD9isUCNnhX8kiRtI","AIzaSyDwkJYSRHny4nvXwj9c2nyJ8mJIkjVkhQE","AIzaSyApHMUzGKghcGDnXLRNIfHqssZwVBEl06U","AIzaSyAKsY2pl_chjc8wxb-C33dFFVn0kf9_M0U"]
estaciones = [readcsv("estacionesn.csv")[2:end,1] readcsv("estacionesn.csv")[2:end,10:11]]
first300 = readdlm("estaciones300.dat", Int64)
# lat, long
#traffic_model = "best_guess"
#transit_mode = "subway"
function manda(j::Int64,mode::Array{ASCIIString,1},origin::AbstractString,destination::AbstractString,keys::Array{ASCIIString,1}, durs::Array{Any,2})
#    l,j,nit = args
#    if sb != nit
#        tam = nit
#    else
#        tam = sb
#    end
    for i = 0:(length(mode)-1) #se realizan los requests en los 4 modos

        URL = "https://maps.googleapis.com/maps/api/directions/json?units=metric&origin=$(origin)&destination=$(destination)&mode=$(mode[i+1])&key=$(keys[1])"
        response = Requests.json(get(URL))
        #produce("recibido")
        #sleep(1)
        println(j,'\t',mode[i+1],'\t',response["status"],'\t', now())
        while response["status"] == "OVER_QUERY_LIMIT" #esta linea es para usar otra key del arreglo, una vez que no se pueda hacer mas requests
            keys = circshift(keys,1)
            URL = "https://maps.googleapis.com/maps/api/directions/json?units=metric&origin=$(origin)&destination=$(destination)&mode=$(mode[i+1])&key=$(keys[1])"
            response = Requests.json(get(URL))
            println(j,'\t',mode[i+1],'\t',response["status"],'\t', now())
        end
        while response["status"] == "UNKNOWN_ERROR" #este while es por si hay errores que son del servidor, asi lo vuelve a mandar.
            response = Requests.json(get(URL))
            println(j,'\t',mode[i+1],'\t',response["status"],'\t', now())
        end
        #if response["rows"][1]["elements"][1]["status"] != "OK"; continue; end #si hay algun otro tipo de error solo va a ignorar el error.
        durs[j,2 + 2*i+1] = response["routes"][1]["legs"][1]["distance"]["value"]
        durs[j,2 + 2*i+2] = response["routes"][1]["legs"][1]["duration"]["value"]
        durs[j,11] = Dates.format(now(), "e, dd u yyyy HH:MM:SS")#now()
    end
    return keys
end

#####################################################AQUI EMPIEZA #############################################################

#usos = int(readcsv("usofilt2_2015.csv"))#el uso de estaciones filtrado
#ns = 452 #numero de estaciones que hay
durs = Array{Any}(301,11)  #es el arreglo de salida
mode = ["driving", "bicycling", "transit","walking"] #los modos que hay para hacer el request
durs[1,1] = "start_id";durs[1,2] = "end_id";durs[1,3] = "driving_dist"; durs[1,4] = "driving_time"; durs[1,5] = "bike_dist";durs[1,6] ="bike_time"
durs[1,7] = "transit_dist"; durs[1,8] = "transit_time"; durs[1,9] = "walking_dist"; durs[1,10] = "walking_time"; durs[1,11] = "date"
println("Initialization passed!")
for j = 2:301
    #mat = usos[usos[:,1].==j,:] #trabaja sobre el indice j de los datos,
    #nit = divrem(size(mat)[1], sb) #se obtiene cuantas iteraciones de 100 y el sobrante para hacer el request
     #aqui se van a construir los bloques para los requests
    lat2 = estaciones[estaciones[:,1].==first300[j-1,2],:][2]; long2 = estaciones[estaciones[:,1].==first300[j-1,2],:][3]
    lat1 = estaciones[estaciones[:,1].==first300[j-1,1],:][2]; long1 = estaciones[estaciones[:,1].==first300[j-1,1],:][3]
    origin = string(lat1,",",long1) #aqui se define la estacion de inicio (coordenadas)
    destination = string(lat2,"%2C",long2);
    durs[j,1] = first300[j-1,1]; durs[j,2] = first300[j-1,2]
    #Aqui se concatenan las de llegada restantes (100 max)
#    for i = 2:sb
#        destination = destination*string("%7C",estaciones[estaciones[:,1].==mat[l*sb+i,2],:][2],"%2C",estaciones[estaciones[:,1].==mat[l*sb+i,2],:][3])
#        durs[j][l*sb+i,1] = mat[l*sb+i,1]; durs[j][l*sb+i,2] = mat[l*sb+i,2]
#    end
    println("Going for the $(j-1) request")
    keys = manda(j,mode,origin,destination,keys,durs) #aqui se hace el request.
    #taskQ = Task(() -> manda(j,mode,origin,destination,key,durs)) #esto es para usarlo como task, solo en el momento de usar sleep.
    #for x in taskQ
    #end

end
println("Requests passed!")
writedlm("/home/alfredo/Dropbox/BiciUso/datos-$(now()).dat",durs)
##################
######################ESTA ES LA SECCION DE PRUEBA ########################################################################################################
#origin = string(estaciones[1,2],",",estaciones[1,3])
#destination = string(estaciones[11,2],"%2C",estaciones[11,3])
#key = "AIzaSyCBZKUNqVU_8-NrMbp_LSoxK37PT-8qV6c"
# ##for i = 2:50
##       #origin = origin*string("|",estaciones[i,2],",",estaciones[i,3])
#    destination = destination*string("%7C",estaciones[i,2],"%2C",estaciones[i,3])
# end
#URL = "https://maps.googleapis.com/maps/api/directions/json?units=metric&origin=$(origin)&destination=$(destination)&mode=$(mode[2])&key=$(key)"
#response = Requests.json(get(URL))
# response["routes"][1]["legs"][1]["distance"]["value"]
# response["routes"][1]["legs"][1]
# #
# destination = string(estaciones[estaciones[:,1].==211,:][2],"%2C",estaciones[estaciones[:,1].==211,:][3])
# origin  = string(estaciones[estaciones[:,1].==217,:][2],",",estaciones[estaciones[:,1].==217,:][3])
