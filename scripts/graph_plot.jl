using Plots, PlotRecipes, LightGraphs
pyplot()
include("funcs.jl")

data_path = "/$(homedir())/Ecobici"

files = filter(x -> ismatch( r"filt_\d+.csv", x), readdir(data_path))

# mes es la columna 3
data = readcsv(data_path*"/"*files[1])[2:end, :]

th = 366
trip = trip_dict(data)

filt_trip = filter((k,v) -> v >= th, trip)

#net1 = DiGraph(get_adj_mat(trip))
net2 = DiGraph(get_adj_mat(filt_trip))



graphplot(net2,
    node_weights=indegree(net2),
    dim=3,
    line = (3, 0.5, :blues),
    marker_z=collect(vertices(net2))
)

gui()

graphplot(A,
    node_weights = 1:n,
    marker = (:heat, :rect),
    line = (3, 0.5, :blues),
    marker_z = 1:n,
    names = 1:n
)
