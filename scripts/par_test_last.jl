@everywhere using DistributedArrays

y = ARGS[1]

# raw_data = readcsv("/home/martin/Documents/datos_ecobici/EcobiciDF/2010.csv") # cubo
raw_data = readcsv("/home/martin/datos_ecobici/EcobiciDF/$(y).csv") # comadreja
#raw_data = readcsv("/Users/martinC3/Google Drive/EcobiciDATA/EcobiciDF/2014.csv")

file = open("filt_$(y).csv", "w")

# Distribuye datos en procesadores
Ddata = distribute(raw_data[2:end, :])
println("pass dist")
println(file, "id_start,id_end,month,day,hour,mins")

for i in 1:size(raw_data,1)
    st_time  = DateTime(Ddata[i,5]*" "*Ddata[i,6], "y-m-d H:M:S.s")
    end_time = DateTime(Ddata[i,8]*" "*Ddata[i,9], "y-m-d H:M:S.s")
    println(file, Ddata[i,4], ",", Ddata[i,7], ",", Dates.month(st_time), ",", Dates.dayofweek(st_time), ",",Dates.value(Dates.Hour(st_time)), ",", round(Int, Dates.value(end_time - st_time) / (60*1000)) )
end

close(file)
println("done")

## //////PRUEBAS//////// ##
# st_time = DateTime(raw_data[2,5]*" "*raw_data[2,6], "y-m-d H:M:S.s")
# end_time = DateTime(raw_data[2,8]*" "*raw_data[2,9], "y-m-d H:M:S.s")
#
# Dates.month(st_time)
# Dates.dayofweek(st_time)
# Dates.value(Dates.hour(st_time))
#
# typeof(Dates.hour(st_time))
#
# round(Int, Dates.value(end_time - st_time) / (60*1000) )
#
# Dates.value(end_time - st_time) / (60*1000)
