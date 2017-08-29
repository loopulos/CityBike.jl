
using Plots, LightGraphs, DataFrames

# using LightGraphs
#using GraphPlot
#using Compose
using DataFrames
using Plots

include("$(homedir())/GitRepos/CityBike.jl/scripts/funcs.jl")
include("funcs.jl")
# histogram(collect(values(trip)))

data_path = "$(homedir())/Google\ Drive/EcobiciDATA/EcobiciDF"
output_path = data_path*"/Graphs/threshold"
# data_path = "$(homedir())/Ecobici"

files = filter(x -> ismatch(r"^filt_.", x), readdir(data_path))
years = [match(r"(\w+_\d+||\w+_\d+-\w+)\.\w+$", f).captures[1] for f in files]
# years = [match(r"(\d+)$", i).captures[1] for i in [match(r"^(\w+_\d+)", f).captures[1] for f in files]]
###=============###================###================###================###
j = 1

data = readcsv(data_path*"/"*files[j])[2:end, :]

m = 2

# filter by month (column 3)
if length(find(x -> x == m, data[:, 3])) != zero(Int)
    month_data = data[find(x -> x == m, data[:, 3]), :]
    trip = trip_dict(month_data)
end

th_vals = linspace(minimum(collect(values(trip))),maximum(collect(values(trip))), 25)
cl_sizes = zeros(length(th_vals))
max_st = zeros(Int, length(th_vals))

labels = Dict()

adj_file = open("$(output_path)/$(years[j])_m_$(m)_th_$(i).csv", "w+")
adj_file = open("$(output_path)/test.csv", "w+")

for i in 1:length(th_vals)
    cl, lab = clusters_th(trip, th_vals[i])

    cl_sizes[i] = maximum(collect(values(cl)))
    labels[i] = lab

    filt_trip = filter((k,v) -> v >= th_vals[i], trip)

    i_st = [k[1] for k in keys(filt_trip)]
    e_st = [k[2] for k in keys(filt_trip)]

    max_st[i] = maximum(unique(union(i_st,e_st)))

    # adj = hcat(i_st, e_st, collect(values(filt_trip)) ./ maximum(collect(values(filt_trip))))
    adj = hcat(i_st, e_st)

    # adj_file = open("$(output_path)/$(years[j])_m_$(m)_th_$(i).csv", "w+")

    # println(adj_file, "Source,Target")
    # println(adj_file, "Source,Target,Weight")

    # for i in 1:size(adj,1)
    #     # println(adj_file, repr(adj[i,:])[5:end-1])
    #     println(adj_file, repr(adj[i,:])[2:end-1])
    # end

    # close(adj_file)

    writecsv("$(output_path)/$(years[j])_m_$(m)_th_$(i).csv", adj)
end

###================###================###================###================###

st_labels = zeros(Int, maximum(max_st), length(th_vals))

for t in keys(labels)
    for st in keys(labels[t])
        st_labels[st, t] = labels[t][st]
    end
end

for i in keys(labels[22])
    println(i, " ", st_labels[i, 22])
end
###================###================###================###================###

st_info = readtable(data_path*"/estacionesn.csv")

# i = 1
for i in 1:length(th_vals)
    # filt_trip = filter((k,v) -> v >= th_vals[i], trip)
    #
    # i_st = [k[1] for k in keys(filt_trip)]
    # e_st = [k[2] for k in keys(filt_trip)]

    # stations = st_info[[find( x -> x == st, st_info[:id])[1] for st in union(i_st,e_st)], [:id, :name,:location_lat, :location_lon] ]
    # stations[:Cluster] = @data([st_labels[i] for i in sort(union(i_st, e_st))])

    # stations = st_info[[find( x -> x == st, st_info[:id])[1] for st in collect(keys(labels[i]))], [:id, :name,:location_lat, :location_lon] ]
    #
    # # stations[:Cluster] = @data([st_labels[j,i] for j in collect(keys(labels[i]))])
    # stations[:Cluster] = @data([labels[i][j] for j in collect(keys(labels[i]))])

    stations = st_info[[find( x -> x == st, st_info[:id])[1] for st in 1:85], [:id, :name,:location_lat, :location_lon] ]
    stations[:Cluster] = st_labels[:, i]


    rename!(stations, :id, :Id)
    rename!(stations, :name, :Label)

    # writetable("$(output_path)/st_data_$(years[j])_m_$(m)_th_$(i).csv", sort(stations, cols = (:Id)))
    writetable("$(output_path)/st_data_$(years[j])_m_$(m)_th_$(i).csv", stations)
end
###================###================###================###================###

stations = st_info[[find( x -> x == st, st_info[:id])[1] for st in collect(keys(labels[i]))], [:id, :name,:location_lat, :location_lon] ]
