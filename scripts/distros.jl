#Script for plotting the distributions of distances between stations and distances in jouneys using CityBike
using PyPlot
using CityBike
#first between stations
#es = readcsv("coordenadasn.csv",Float64)
es = readcsv("/media/alfredo/Killer-Rabbit1.5/Ecobicis/EcobiciBuenosAires/estaciones.csv")
dists = cons_vdist(es)
bins, counts = hist(dists[:,3], 20)
plt[:plot](collect(midpoints(bins)), counts / length(dists[:,3]), ".-")
plt[:xlabel]("distance(km)")
plt[:ylabel]("P(d)")
plt[:title]("Distance distribution between stations BuenosAires")
plt[:grid](true)

#I need to construct a dictionary with the distances.
Dist = Dict{String, Float64}()
tam = length(dists[:,1])
for i = 1:tam
    ab = string(dists[i,1], ',' , dists[i,2])
    Dist[ab] = dists[i,3]
end
#now the journeys
cd("/home/alfredo/Google Drive/EcobiciDATA/EcobiciNYC")
#cd("/home/alfredo/Google Drive/EcobiciDATA/EcobiciDF")
pwd()

files = readdir()

travs_files = [files[i] for i in find(x -> ismatch( r"filt_\d+.csv", x), files)]


for file in travs_files

    data = readcsv(file)

    # println(size(data))

    dist_travs = Float64[data[2:end, 1] data[2:end, 2]]
    l = length(dist_travs[:,1])
    dists_ = Array{Float64,1}()

    for i = 1:l
        if dist_travs[i,1] == dist_travs[i,2]; continue; end
        if dist_travs[i,1] >= 1000 || dist_travs[i,2] >= 1000; continue; end
        if haskey(Dist, string(dist_travs[i,1],',',dist_travs[i,2]))
            ab = string(dist_travs[i,1],',',dist_travs[i,2])
            push!(dists_, Dist[ab])
        else
            ab = string(dist_travs[i,2],',',dist_travs[i,1])
            push!(dists_, Dist[ab])
        end
    end

    #dur_travs_filt = Int64[dur_travs[i] for i in find(x -> x <= 50 && x > 0, dur_travs)]

    bins, counts = hist(dists_, 200)
    plt[:plot](collect(midpoints(bins)), counts / length(dists_), ".-", label = replace(split(file,"_")[2], ".csv", ""))

    # plt[:hist](dur_travs_filt, bins=100, normed=true, label = file)
end
plt[:legend]()
plt[:xlabel]("distance(km)")
plt[:ylabel]("P(d)")
plt[:title]("Journeys distance distribution NY")
plt[:grid](true)
