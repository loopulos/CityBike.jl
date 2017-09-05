
using Plots, LightGraphs, DataFrames

using LightGraphs
using Plots, DataFrames

include("$(homedir())/GitRepos/CityBike.jl/scripts/funcs.jl")
# include("funcs.jl")
# histogram(collect(values(trip)))

data_path = "$(homedir())/Google\ Drive/EcobiciDATA/EcobiciDF"
# data_path = "$(homedir())/Ecobici"

output_path = data_path*"/Graphs/threshold"
output_path = data_path*"/Graphs/csv_data"

# fig_path = data_path*"/perc_month"
fig_path = data_path*"/perc_year"

files = filter(x -> ismatch(r"^filt_.", x), readdir(data_path))
years = [match(r"(\w+_\d+||\w+_\d+-\w+)\.\w+$", f).captures[1] for f in files]

###=============###================###================###================###

j = 2
data = readcsv(data_path*"/"*files[2])[2:end, :]
trip = trip_dict(data)

th_vals = linspace(minimum(collect(values(trip))),maximum(collect(values(trip))), 25)
cl_sizes = zeros(length(th_vals))
max_st = zeros(Int, length(th_vals))

labels = Dict()

for i in 1:length(th_vals)
    cl, lab = clusters_th(trip, th_vals[i])
    cl_sizes[i] = maximum(collect(values(cl)))

    labels[i] = lab

    filt_trip = filter((k,v) -> v >= th_vals[i], trip)

    i_st = [k[1] for k in keys(filt_trip)]
    e_st = [k[2] for k in keys(filt_trip)]

    max_st[i] = maximum(unique(union(i_st,e_st)))

    adj = hcat(i_st, e_st)
    # adj = hcat(i_st, e_st, collect(values(filt_trip)) ./ sum(collect(values(trip))))

    # adj_file = open("$(output_path)/$(years[j])_m_$(m)_th_$(i).csv", "w+")

    println(adj_file, "Source,Target")
    # println(adj_file, "Source,Target,Weight")

    for i in 1:size(adj,1)
        println(adj_file, join(split(strip(repr(adj[i,:]), ['[', ']', ' ']))))
    end

    # close(adj_file)

    writecsv("$(output_path)/$(years[j])_m_$(m)_th_$(i).csv", adj)
end

plot(collect(th_vals), cl_sizes, m = :o)

i_st = [k[1] for k in keys(trip)]
e_st = [k[2] for k in keys(trip)]

# todas las estaciones posibles
all_st = maximum(unique(union(i_st,e_st)))

plot(collect(th_vals) , cl_sizes ./ all_st, m = :o, leg = false)
plot(collect(th_vals)./365 , cl_sizes ./ all_st, m = :o, leg = false)

ceil(th_vals[7]) #2010

th = Dict()

# umbral de "percolacion"
th[2010] = 366.
th[2011] = 942.
th[2012] = 618.
th[2013] = 1124.
th[2014] = 1215.
th[2015] = 1217.
th[2016] = 1886.

th = [366. ,942., 618., 1124., 1215., 1217., 1886.]


###================###================###================###================###

filt_trip = filter((k,v) -> v >= th[7], trip)

i_st = [k[1] for k in keys(filt_trip)]
e_st = [k[2] for k in keys(filt_trip)]


writecsv("adj_2016.csv",hcat(i_st, e_st, collect(values(filt_trip))))
writecsv("adj_2016.csv",hcat(i_st, e_st))

hcat(i_st, e_st, collect(values(filt_trip)))

###================###================###================###================###

st_info = readtable(data_path*"/estacionesn.csv")

writetable("st_name_2016.csv", sort(st_info[find( x -> in(x, union(i_st, e_st)), st_info[:id]), [:id, :name,:location_lat, :location_lon] ], cols = (:id)))


st_name = get_dict_st(readcsv(data_path*"/estacionesn.csv"))

writecsv("st_name_2011.csv", hcat(sort(union(i_st, e_st)), [st_name[i][1] for i in sort(union(i_st, e_st))]))
###================###================###================###================###

trip = trip_dict(data)
filt_trip = filter((k,v) -> v >= th[i], trip)

net = DiGraph(get_adj_mat(trip))
net = DiGraph(get_adj_mat(filt_trip))

deg_h_in = degree_histogram(net, indegree)

scatter(collect(keys(deg_h_in)), collect(values(deg_h_in)), m = :o,  xscale = :log10, yscale = :log10, xlims = (1, maximum(collect(keys(deg_h_in)))), ylims = (1, maximum(collect(values(deg_h_in)))), label = "in")

scatter(collect(keys(deg_h_in)), collect(values(deg_h_in)), m = :o, label = "in")

deg_h_out = degree_histogram(net, outdegree)

scatter!(collect(keys(deg_h_out)), collect(values(deg_h_out)), m = :o,  xscale = :log10, yscale = :log10, xlims = (1, maximum(collect(keys(deg_h_out)))), ylims = (1, maximum(collect(values(deg_h_out)))), label = "out")

scatter!(collect(keys(deg_h_out)), collect(values(deg_h_out)), m = :o,  xscale = :log, yscale = :log, xlims = (1, maximum(collect(keys(deg_h_out)))), ylims = (1, maximum(collect(values(deg_h_out)))), label = "out")

scatter!(collect(keys(deg_h_out)), collect(values(deg_h_out)), m = :o, label = "out")


###================###================###================###================###

plot(sort(indegree(net), rev = true), xlims = (1, maximum(indegree(net))), xscale = :log10, yscale = :log10)
plot!(sort(outdegree(net), rev = true), xlims = (1, maximum(outdegree(net))), xscale = :log10, yscale = :log10)

plot(sort(indegree(net), rev = true), xlims = (1, maximum(indegree(net))), label = "in", m = :o)
plot!(sort(outdegree(net), rev = true), xlims = (1, maximum(outdegree(net))), label = "out", m = :o)

in_hub = find(x -> indegree(net)[x] == Δin(net), collect(vertices(net)))
out_hub = find(x -> outdegree(net)[x] == Δout(net), collect(vertices(net)))

st_name[in_hub[1]]
st_name[out_hub[1]]

top = 10

in_hubs = Vector{Vector{Int}}(6)
out_hubs = Vector{Vector{Int}}(6)

th = [366. ,942., 618., 1124., 1215., 1217.]

for m in 1:6

    println(m)

    data = readcsv(data_path*"/"*files[m])[2:end, :]

    trip = trip_dict(data)

    filt_trip = filter((k,v) -> v >= th[m], trip)

    net = DiGraph(get_adj_mat(filt_trip))

    in_hubs[m] = sortperm(indegree(net), rev = true)[1:top]
    out_hubs[m] = sortperm(outdegree(net), rev = true)[1:top]
end

# [st_st_name[i][1] for i in sortperm(indegree(net), rev = true)[1:top]]
plot(in_hubs, collect(1:10),  m = :)o)
g_uei()

writecsv("in_hubs_year.csv", hcat(collect(1:10), in_hubs...))
writecsv("out_hubs_year.csv", hcat(collect(1:10), out_hubs...))
