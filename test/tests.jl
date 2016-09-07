using JLD

data_estaciones = readcsv("estacionesn.csv")

dict_est = Dict()

for i in 2:size(data_estaciones,1)

  dict_est[data_estaciones[i, 1]] = data_estaciones[i, 10:11]

end

pwd()

save("loc_estaciones.jld", "dict_est", dict_est)

s = load("loc_estaciones.jld", "dict_est")
