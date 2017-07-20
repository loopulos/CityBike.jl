using Plots, PlotRecipes, LightGraphs
pyplot()
include("funcs.jl")

data_path = "/$(homedir())/Ecobici"

files = filter(x -> ismatch( r"filt_\d+.csv", x), readdir(data_path))

# mes es la columna 3
data = readcsv(data_path*"/"*files[1])[2:end, :]

th = 90
trip = trip_dict(data)

filt_trip = filter((k,v) -> v >= th, trip)

net1 = DiGraph(get_adj_mat(trip))
net2 = DiGraph(get_adj_mat(filt_trip))

degree(net2)

graphplot(A,
    node_weights = 1:n,
    marker = (:heat, :rect),
    line = (3, 0.5, :blues),
    marker_z = 1:n,
    names = 1:n
)
graphplot(net2, node_weights=degree(net2),marker = (:heat, :rect))

gui()
