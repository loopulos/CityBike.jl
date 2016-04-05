using PyPlot

# cd("/home/martin/Documents/datos_ecobici/EcobiciDF") #cubo
cd("/Users/martinC3/Google Drive/EcobiciDATA/EcobiciDF") #C3

pwd()

files = readdir()

travs_files = [files[i] for i in find(x -> ismatch( r"filt_\d+.csv", x), files)]

for file in travs_files

    data = readcsv(file)

    # println(size(data))

    dur_travs = convert(Array{Int64,1}, data[2:end, 6])
    dur_travs_filt = Int64[dur_travs[i] for i in find(x -> x <= 50 && x > 0, dur_travs)]

    bins, counts = hist(dur_travs_filt, 100)
    plt[:plot](collect(midpoints(bins)), counts / length(dur_travs_filt), ".-", label = replace(split(file,"_")[2], ".csv", ""))

    # plt[:hist](dur_travs_filt, bins=100, normed=true, label = file)
end

# plt[:legend](bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
plt[:legend](loc = "upper right")
plt[:grid](true)
plt[:xlabel]("t")
plt[:ylabel]("P(t)")

plt[:xlabel]("h")
plt[:ylabel]("P(h)")

plt[:title]("Duracion viajes")
plt[:title]("Weekday")
plt[:title]("Weekend")

plt[:clf]()

# filtra dias entre semana y fines de semana
for file in travs_files
    data = readcsv(file)

    weekday_hr = Int64[data[i+1, 5] for i in find(x -> x in 1:5, data[2:end, 4])]

    bins, counts = hist(weekday_hr, 24)
    plt[:plot](collect(midpoints(bins)), counts / length(weekday_hr), ".-", label = replace(split(file,"_")[2], ".csv", ""))
end


# fines de semana
for file in travs_files
    data = readcsv(file)

    weekend_hr = Int64[data[i+1, 5] for i in find(x -> x in 6:7, data[2:end, 4])]
    bins, counts = hist(weekend_hr, 24)
    plt[:plot](collect(midpoints(bins)), counts / length(weekend_hr), ".-", label = replace(split(file,"_")[2], ".csv", ""))
end
