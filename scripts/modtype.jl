using JLD

println("workers : $(nworkers())")

raw_data = readcsv("/home/martin/Documents/datos_ecobici/EcobiciDF/2010.csv") # cubo

# Encuentra viajes con status "A"
trav_A = find( x -> x == "A  ", raw_data[:,7])

# Datos filtrados, solo viajes con status A
data = raw_data[trav_A,:]

# for i in 1:size(raw_data,1)
#     data[i, 3] = DateTime(data[i,3], "y-m-d H:M:S")
#     data[i, 5] = DateTime(data[i,5], "y-m-d H:M:S")
# end

# @parallel for i = 1:size(raw_data,1)
@sync @parallel for i = 1:100
    data[i, 3] = DateTime(data[i,3], "y-m-d H:M:S")
    data[i, 5] = DateTime(data[i,5], "y-m-d H:M:S")
end

println("End conversion")

jldopen("trav_2010.jld","w") do file
    write(file, "viajes", data[1:100,:])
end

println("Done")
