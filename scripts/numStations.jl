using PyPlot

cd("/home/martin/Documents/datos_ecobici/EcobiciDF") #cubo
# cd("/Users/martinC3/Google Drive/EcobiciDATA/EcobiciDF") #C3

pwd()

files = filter(x -> ismatch( r"filt_\d+.csv", x), readdir())

for file in files

    data = readcsv(file)

    used_stations = Dict()

    for i in 1:2
        for val in data[2:end,i]
            if val < 500
                haskey(used_stations, val) == false ? used_stations[val] = 1 : used_stations[val] += 1
            end
        end
    end

    keys_sort = sort(Int64[val for val in keys(used_stations)])
    vals_sort = Float64[used_stations[key] for key in keys_sort]

    tot_counts = sum(Float64[val for val in values(used_stations)])

    # plt[:plot](keys_sort, vals_sort ./ tot_counts, ".-", label = file)
    plt[:bar](keys_sort, vals_sort ./ tot_counts, 1.0, label = file)

end

# salida y entrada diferente
# for file in files

file = files[6]

data = readcsv(file)

out_stations = Dict()
in_stations  = Dict()

for val in data[2:end,1]
    if val < 500
        haskey(out_stations, val) == false ? out_stations[val] = 1 : out_stations[val] += 1
    end
end

for val in data[2:end,2]
    if val < 500
        haskey(in_stations, val) == false ? in_stations[val] = 1 : in_stations[val] += 1
    end
end

out_keys_sort = sort(Int64[val for val in keys(out_stations)])
in_keys_sort  = sort(Int64[val for val in keys(in_stations)])

out_vals_sort = Float64[out_stations[key] for key in out_keys_sort]
in_vals_sort  = Float64[in_stations[key] for key in in_keys_sort]

out_tot_counts = sum(Float64[val for val in values(out_stations)])
in_tot_counts  = sum(Float64[val for val in values(in_stations)])

println(out_tot_counts, "\t", in_tot_counts)

plt[:plot](out_keys_sort, out_vals_sort ./ out_tot_counts, ".-", label = "out_"*replace(split(file, ".")[1], "filt_", ""))
plt[:plot](in_keys_sort, in_vals_sort ./ in_tot_counts, ".-", label = "in_"*replace(split(file, ".")[1], "filt_", ""))

# end

# numero de estaciones por mes por anio
for file in files

    data = readcsv(file)

    num_st = Dict()

    for month in 1:12

        stations = Dict()

        trip_month = find(x -> x == month, data[:,3])

        for i in trip_month
            # salida
            if data[i,1] < 500
                haskey(stations, data[i,1]) == false ? stations[data[i,1]] = 1 : stations[data[i,1]] += 1
            end

            # llegada
            if data[i,2] < 500
                haskey(stations, data[i,2]) == false ? stations[data[i,2]] = 1 : stations[data[i,2]] += 1
            end
        end

        num_st[month] = length(keys(stations))
    end

    keys_sort = sort(Int64[val for val in keys(num_st)])
    vals_sort = Int64[num_st[key] for key in keys_sort]

    plt[:plot](keys_sort, vals_sort, ".-", label = replace(split(file, ".")[1], "filt_", "") )
end

data = readcsv(files[1])

union(find(x -> x < 500, data[2:end,1]), find(x -> x < 500, data[2:end,2]))

intersect(find(x -> x == 2, data[2:end,3]), find(x -> x < 500, data[2:end,1]))

find( x -> x < 500, [data[i,2] for i in find(x -> x == 2, data[2:end,3])] )

for i in find(x -> x == 1, data[2:end,3])
    if data[i,1] < 500
        println(data[i,1])
    end
end

plt[:grid](true)
plt[:legend](loc="upper left")
plt[:legend](loc="upper right")

plt[:title]("Numero de estaciones por mes por año")
plt[:xlabel]("Mes")
plt[:ylabel]("Número de estaciones")

plt[:title]("Uso anual por estación")
plt[:xlabel]("ID Estación")
plt[:ylabel]("P(ID)")

plt[:clf]()

sum(collect(1:10))

collect(1:10)
