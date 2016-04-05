@everywhere using DistributedArrays

y = ARGS[1]

# raw_data = readcsv("/home/martin/Documents/datos_ecobici/EcobiciDF/2010.csv") # cubo
raw_data = readcsv("/home/martin/datos_ecobici/EcobiciDF/$(y).csv") # comadreja

file = open("filt_$(y).csv", "w")

# Distribuye datos en procesadores
Ddata = distribute(raw_data[2:end, :])
println("pass dist")

println(file, "id_start,id_end,month,day,hour,mins")

for i in 1:size(raw_data,1)
    st_time  = DateTime(Ddata[i,5]*" "*Ddata[i,6], "y-m-d H:M:S.s")
    end_time = DateTime(Ddata[i,8]*" "*Ddata[i,9], "y-m-d H:M:S.s")
    println(file, Ddata[i,4], ",", Ddata[i,7], ",", Dates.month(st_time), ",", Dates.dayofweek(st_time), ",",Dates.value(Dates.Hour(st_time)), ",", Dates.value(Dates.Minute(end_time - st_time)))
end

close(file)
println("done")
