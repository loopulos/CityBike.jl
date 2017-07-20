
using Plots, LightGraphs, GraphPlot
using LightGraphs
using GraphPlot
using Compose

include("funcs.jl")

gui()
gr()
pyplot()

###================###================###================###================###

data_path = "/$(homedir())/Google\ Drive/EcobiciDATA/EcobiciDF"
data_path = "/$(homedir())/Ecobici"

files = filter(x -> ismatch( r"filt_\d+.csv", x), readdir(data_path))

# mes es la columna 3
data = readcsv(data_path*"/"*files[1])[2:end, :]

###================###================###================###================##

m = 12
# for m in 1:12
month_data = view(data, find(x -> x == m, data[:,3]), 1:2)

trip = trip_dict(data)

histogram(collect(values(trip)))

###================###================###================###================###


th_vals = linspace(minimum(collect(values(trip))),maximum(collect(values(trip))), 25)
cl_sizes = zeros(length(th_vals))

for i in 1:length(th_vals)
    cl, lab = clusters_th(trip, th_vals[i])
    cl_sizes[i] = maximum(collect(values(cl)))
end

plot(collect(th_vals), cl_sizes, m = :o)

i_st = [k[1] for k in keys(trip)]
e_st = [k[2] for k in keys(trip)]

# todas las estaciones posibles
all_st = maximum(unique(union(i_st,e_st)))

plot(collect(th_vals) , cl_sizes ./ all_st, m = :o, leg = false)
plot(collect(th_vals)./365 , cl_sizes ./ all_st, m = :o, leg = false)

# umbral de "percolacion"
th = ceil(th_vals[6])

###================###================###================###================###

filt_trip = filter((k,v) -> v >= th, trip)

net = DiGraph(get_adj_mat(trip))
net = DiGraph(get_adj_mat(filt_trip))

deg_h_in = degree_histogram(net, indegree)

scatter(collect(keys(deg_h_in)), collect(values(deg_h_in)), m = :o,  xscale = :log10, yscale = :log10, xlims = (1, maximum(collect(keys(deg_h_in)))), ylims = (1, maximum(collect(values(deg_h_in)))), label = "in")

scatter(collect(keys(deg_h_in)), collect(values(deg_h_in)), m = :o, label = "in")

deg_h_out = degree_histogram(net, outdegree)

scatter!(collect(keys(deg_h_out)), collect(values(deg_h_out)), m = :o,  xscale = :log10, yscale = :log10, xlims = (1, maximum(collect(keys(deg_h_out)))), ylims = (1, maximum(collect(values(deg_h_out)))), label = "out")

scatter!(collect(keys(deg_h_out)), collect(values(deg_h_out)), m = :o,  xscale = :log, yscale = :log, xlims = (1, maximum(collect(keys(deg_h_out)))), ylims = (1, maximum(collect(values(deg_h_out)))), label = "out")

scatter!(collect(keys(deg_h_out)), collect(values(deg_h_out)), m = :o, label = "out")


i_st = [k[1] for k in keys(filt_trip)]
e_st = [k[2] for k in keys(filt_trip)]

writecsv("adj_test.csv",hcat(i_st, e_st))
