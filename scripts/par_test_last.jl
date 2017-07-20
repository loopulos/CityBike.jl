@everywhere using DistributedArrays
using Base.Dates
#next function is to fix the problem of the time format.
function parsedate(ds)
    clean = strip(replace(ds, r"(AM|PM)", ""))
    date  = DateTime(clean, DateFormat("y-m-d HH:MM:SS.s"))
    if contains(ds, "PM") && hour(date) != 12
        date += Hour(12)
    elseif contains(ds, "AM") && hour(date) == 12
        date -= Hour(12)
    end
    return date
end

#y = ARGS[1]
y = "2016"

# raw_data = readcsv("/home/martin/Documents/datos_ecobici/EcobiciDF/2010.csv") # cubo
#raw_data = readcsv("/home/martin/datos_ecobici/EcobiciDF/$(y).csv") # comadreja
#raw_data = readcsv("/Users/martinC3/Google Drive/EcobiciDATA/EcobiciDF/2014.csv")
#raw_data = readcsv("/media/alfredo/Killer-Rabbit1.5/Ecobicis/CDMX/$(y).csv")
raw_data = readcsv("/home/alfredo/2016/$(y).csv")


file = open("filt_$(y).csv", "w")

# Distribuye datos en procesadores
Ddata = distribute(raw_data[2:end, :])
println("pass dist")
println(file, "id_start,id_end,month,day,hour,mins")
for i in 1:size(Ddata,1)
    try
        st_time  = parsedate(join([Ddata[i,5],Ddata[i,6]]," "))
        end_time = parsedate(join([Ddata[i,8],Ddata[i,9]]," "))
        # println(file, Ddata[i,3], ",", Ddata[i,4], ",", Dates.month(st_time), ",", Dates.dayofweek(st_time), ",",Dates.value(Dates.Hour(st_time)), ",", round(Int, Dates.value(end_time - st_time) / (60*1000)) )
        println(file, Ddata[i,4], ",", Ddata[i,7], ",", Dates.month(st_time), ",", Dates.dayofweek(st_time), ",",Dates.value(Dates.Hour(st_time)), ",", round(Int, Dates.value(end_time - st_time) / (60*1000)) )
    catch
        println(Ddata[i,3],'\t', i)
    end
end

#sd = join([Ddata[1,5],Ddata[1,6]]," ")
#parsedate(sd)
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
