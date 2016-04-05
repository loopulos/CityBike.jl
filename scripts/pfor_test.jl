#raw_data = readcsv("/home/martin/Documents/datos_ecobici/EcobiciDF/2010.csv") # cubo
raw_data = readcsv("/home/martin/datos_ecobici/EcobiciDF/2010.csv") # comadreja

file = open("filt_2010.csv", "w")

# Encuentra viajes con status "A"
trav_A = find( x -> x == "A  ", raw_data[:,7])

# Datos filtrados, solo viajes con status A
data = raw_data[trav_A,:]

# Distribuye datos en procesadores
# Ddata = distribute(data)
# println("pass dist")

println(file, "id_start,id_end,month,day,duration")

@sync @parallel for i = 1:10000
    st_time = DateTime(data[i,3], "y-m-d H:M:S")
    end_time = DateTime(data[i,5], "y-m-d H:M:S")
    # println(file, data[i,4],",",data[i,6],",",Dates.month(st_time),",",Dates.dayofweek(st_time),",",Int(Dates.Minute(end_time - st_time)))
    println(file, data[i,4],",",data[i,6],",",Dates.month(st_time),",",Dates.dayofweek(st_time),",",Dates.value(Dates.Minute(end_time - st_time)))
end

close(file)
println("done")
