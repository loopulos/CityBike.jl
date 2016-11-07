using Requests
keys = ["AIzaSyCXia5c3mcH4rxdFtLl6qOew0g_W5qOGrE","AIzaSyDrhZkvOxrJkyCYwr17i7evXod8LCF1AEo","AIzaSyAryDOjorWqN5UIPG0uDQ3Ka2SNQnjjC0M","AIzaSyAKnBvFaRTFSqmIypjDsUvuqVbP-aKeIVg","AIzaSyDm2onf5ESbukrMTooYIL1Ln89ulcdtmkg","AIzaSyDXAlJ1PM0nnIPZGkia5GynofyoayRlG_o","AIzaSyD7ba-NzLSKOvkMYBoqZeMktSvfKn4cy9M"]
estaciones = [readcsv("estacionesn.csv")[2:end,1] readcsv("estacionesn.csv")[2:end,10:11]]
first300 = readdlm("estaciones300.dat", Int64)
# lat, long
#traffic_model = "best_guess"
#transit_mode = "subway"
function manda(j::Int64,mode::Array{ASCIIString,1},origin::AbstractString,destination::AbstractString,key::AbstractString, durs::Array{Float64,2})
#    l,j,nit = args
#    if sb != nit
#        tam = nit
#    else
#        tam = sb
#    end
    for i = 0:(length(mode)-1) #se realizan los requests en los 3 modos

        URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$(origin)&destinations=$(destination)&mode=$(mode[i+1])&key=$(key)"
        response = Requests.json(get(URL))
        produce("recibido")
        #sleep(1)
        println(j,'\t',mode[i+1],'\t',response["status"])
        if response["rows"][1]["elements"][1]["status"] != "OK"; continue; end
        durs[j,2 + 2*i+1] = response["rows"][1]["elements"][1]["distance"]["value"]
        durs[j,2 + 2*i+2] = response["rows"][1]["elements"][1]["duration"]["value"]
    end
end
######################ESTA ES LA SECCION DE PRUEBA ########################################################################################################
#origin = string(estaciones[1,2],",",estaciones[1,3])
# destination = string(estaciones[11,2],"%2C",estaciones[11,3])
## for i = 2:50
##       #origin = origin*string("|",estaciones[i,2],",",estaciones[i,3])
#    destination = destination*string("%7C",estaciones[i,2],"%2C",estaciones[i,3])
# end
# URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$(origin)&destinations=$(destination)&mode=$(mode[2])&key=$(key)"
# response = Requests.json(get(URL))
# response["rows"][1]["elements"][1]["distance"]["value"]
# response["rows"][1]["elements"][1]["duration"]["value"]
#
# destination = string(estaciones[estaciones[:,1].==211,:][2],"%2C",estaciones[estaciones[:,1].==211,:][3])
# origin  = string(estaciones[estaciones[:,1].==217,:][2],",",estaciones[estaciones[:,1].==217,:][3])
#####################################################AQUI EMPIEZA #############################################################

#usos = int(readcsv("usofilt2_2015.csv"))#el uso de estaciones filtrado
#ns = 452 #numero de estaciones que hay
durs = zeros(300,8)  #es el arreglo de salida
mode = ["driving", "bicycling", "transit"] #los modos que hay para hacer el request #tamanio del bloque
key = keys[1]

for j = 1:300
    #mat = usos[usos[:,1].==j,:] #trabaja sobre el indice j de los datos,
    #nit = divrem(size(mat)[1], sb) #se obtiene cuantas iteraciones de 100 y el sobrante para hacer el request
     #aqui se van a construir los bloques para los requests
    lat2 = estaciones[estaciones[:,1].==first300[j,2],:][2]; long2 = estaciones[estaciones[:,1].==first300[j,2],:][3]
    lat1 = estaciones[estaciones[:,1].==first300[j,1],:][2]; long1 = estaciones[estaciones[:,1].==first300[j,1],:][3]
    origin = string(lat1,",",long1) #aqui se define la estacion de inicio (coordenadas)
    destination = string(lat2,"%2C",long2);
    durs[j,1] = first300[j,1]; durs[j,2] = first300[j,2]
    #Aqui se concatenan las de llegada restantes (100 max)
#    for i = 2:sb
#        destination = destination*string("%7C",estaciones[estaciones[:,1].==mat[l*sb+i,2],:][2],"%2C",estaciones[estaciones[:,1].==mat[l*sb+i,2],:][3])
#        durs[j][l*sb+i,1] = mat[l*sb+i,1]; durs[j][l*sb+i,2] = mat[l*sb+i,2]
#    end
    taskQ = Task(() -> manda(j,mode,origin,destination,key,durs))
    for x in taskQ
    end
    #falta enviar el request faltante (sobrante de n/sb)

    # lat2 = estaciones[estaciones[:,1].==mat[nit[1]*sb+1,2],:][2]; long2 =estaciones[estaciones[:,1].==mat[nit[1]*sb+1,2],:][3]
    # destination = string(lat2,"%2C",long2)
    # for i = 2:nit[2]
    #     destination = destination*string("%7C",estaciones[estaciones[:,1].==mat[nit[1]*sb+i,2],:][2],"%2C",estaciones[estaciones[:,1].==mat[nit[1]*sb+i,2],:][3])
    #     durs[j][nit[1]*sb+i,1] = mat[nit[1]*sb+i,1]; durs[j][nit[1]*sb+i,2] = mat[nit[1]*sb+i,2]
    # end
    # args = [nit[1],sb,nit[2]]
    # taskQ = Task(() -> manda(args,mode,origin,destination,key,durs[j]))
    # for x in taskQ
    # end
end
writedlm("datos.dat",durs)
##################
