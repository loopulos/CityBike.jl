
using DataFrames, StatPlots

g_drive_path = "/Users/mzumaya/Google Drive/EcobiciDATA/EcobiciDF"

##================##================##
# Carga datos

st_300 = readtable("/Users/mzumaya/GitRepos/CityBike.jl/test/estaciones300.dat", header = false,  separator = ' ', names = [:id_st, :id_end, :freq])

dists = readtable(g_drive_path*"/distest.csv", header = false,  separator = ',', names = [:id_st, :id_end, :dist])

coordenadas = readtable(g_drive_path*"/coordenadasn.csv", header = false,  separator = ',', names = [:id, :lat, :long])

raw_use = filter(x -> ismatch(r"^\d+.csv", x), readdir(g_drive_path))

data = readtable(g_drive_path * "/" *raw_use[6])

rename!(data, [:Ciclo_Estacion_Retiro, :Ciclo_Estacion_Arribo], [:id_st, :id_end])

data[:time_st]  = map((x,y) -> x*" "*y, data[:Fecha_Retiro], data[:Hora_Retiro] )
data[:time_end] = map((x,y) -> x*" "*y, data[:Fecha_Arribo], data[:Hora_Arribo] )

delete!(data, :Fecha_Retiro)
delete!(data, :Fecha_Arribo)

delete!(data, :Hora_Retiro)
delete!(data, :Hora_Arribo)

delete!(data, :Genero_Usuario)
delete!(data, :Edad_Usuario)
delete!(data, :Bici)

data[:travel_time] = map((x, y) -> (x-y).value / (1000*60), DateTime(data[:time_end], "y-m-d HH:MM:SS.sssss"), DateTime(data[:time_st], "y-m-d HH:MM:SS.sssss"))

writetable("uso_2015_mod.csv", data)

find(x -> x < 0, data[:travel_time])

# formato de fecha 2015
date_format = Dates.DateFormat("y-m-d")

# identifica estaciones de salida
st_leave = unique(st_300[:id_st].data)

##================##================##

# considera solo viajes en los 300

travs_300 = join(data, st_300, on = [:id_st, :id_end], kind = :inner)[4:end]

travs_300[:dur] = map((x, y) -> (y - x).value / (1000 *  60), DateTime(travs_300[:, :Hora_Retiro], "HH:MM:SS.ssssss"), DateTime(travs_300[:, :Hora_Arribo], "HH:MM:SS.ssssss"))

# travs_300[:dur] = broadcast(x -> x.value / (1000 * 60), DateTime(travs_300[:, :Hora_Arribo], "HH:MM:SS.ssss") - DateTime(travs_300[:, :Hora_Retiro], "HH:MM:SS.ssss"))

println(travs_300)

println(travs_300[find( x -> x < 0., travs_300[:dur]), :])

map((x,y) -> x*" "*y, travs_300[:Fecha_Retiro], travs_300[:Hora_Retiro] )

DateTime(travs_300[1, :Fecha_Retiro]*" "*travs_300[1, :Hora_Retiro], "y-m-d HH:MM:SS.sssss")

# println(unique(dists[:id_end]))
# println(unique(st_300[:id_end]))
# println(sort!(coordenadas))

##================##================##

# rutas para estacion de salida
travs = st_300[st_300[:id_st] .== st_leave[1], :]
println(travs)

# se realiza ciclo sobre rutas (parejas de estaciones)
size(travs)

# viajes filtrados
filt_travs = travs_300[(travs_300[:id_st] .== travs[1, :id_st]) & (travs_300[:id_end] .== travs[1, :id_end]), :]

println(filt_travs)

map((x, y) -> (y - x).value / (1000 *  60), DateTime(filt_travs[:, :Hora_Retiro], "HH:MM:SS.ssssss"), DateTime(filt_travs[:, :Hora_Arribo], "HH:MM:SS.ssssss"))

extrema(filt_travs[:dur])

histogram(filt_travs[:dur], normalized = true)

##================##================##

println(sort!(join(dists, st_300, on = [:id_st, :id_end], kind = :inner), cols = [:id_st]))
println(dists)

##================##================##

# viajes entre semana
wd_h = histogram(Dates.hour(DateTime(filt_travs[find( x -> x <= 4, Dates.dayofweek(Date(filt_travs[:, :Fecha_Retiro], date_format))), :][:Hora_Arribo], "HH:MM:SS.sss")), nbins = 24)

# viajes fin de semana
wk_h = histogram(Dates.hour(DateTime(filt_travs[find( x -> x > 4, Dates.dayofweek(Date(filt_travs[:, :Fecha_Retiro], date_format))), :][:Hora_Arribo], "HH:MM:SS.sss")), nbins = 24)

plot(wd_h, wk_h, layout = @layout([mg ; sct]), leg = false)

##================##================##
