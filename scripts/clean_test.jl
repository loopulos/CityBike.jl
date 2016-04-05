using HDF5, JLD

#Carga Datos
raw_data = readcsv("/Users/mzumaya/Google Drive/EcobiciDATA/EcobiciDF/2010.csv") # mac
raw_data = readcsv("/home/martin/Documents/datos_ecobici/EcobiciDF/2010.csv") # cubo

size(raw_data)

# Encuentra viajes con status "A"
trav_A = find( x -> x == "A  ", raw_data[:,7])

# Datos filtrados, solo viajes con status A
data = raw_data[trav_A,:]

# vector para duracion de viajes
dur_travel = zeros(length(trav_A))
dur_travel = zeros(10)

data[8,:]
dur_travel

# convierte fechas a formato de julia para manejarlas
# for i in 1:size(raw_data,1)
for i in 1:10
    data[i, 3] = DateTime(data[i,3], "y-m-d H:M:S")
    data[i, 5] = DateTime(data[i,5], "y-m-d H:M:S")
end

data[1:10,:]

save("test.jld", "viajes", data[1:10,:])
data_test = jldopen("test.jld", "r")
travels = read(data_test, "viajes")

travels[1, 3]

# calcula duracion de viajes
for i in 1:10
    dur_travel[i] = (data[i, 5] - data[i, 3]) / (1000 * 60) # duracion del viaje en minutos
end
