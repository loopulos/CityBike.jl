using Plots, LightGraphs, GraphIO, DataFrames
include("funcs.jl")
data_path = "/media/alfredo/Killer-Rabbit1.5/Ecobicis/CDMX/Filt/threshold"
st_info = readtable("/media/alfredo/Killer-Rabbit1.5/Ecobicis/CDMX/Filt/estacionesn.csv")

files = filter(x -> ismatch(r"^filt_2012_m_.+_th_7", x), readdir(data_path))

for file in files
    data = readcsv(data_path*"/$(file)")
    i_st = map(Int64, data[:,1])
    e_st = map(Int64, data[:,2])
    all_st = sort(unique(union(i_st,e_st)))
    stations = st_info[[find( x -> x == st, st_info[:id])[1] for st in all_st], [:id, :name,:location_lat, :location_lon] ]

    rename!(stations, :id, :Id)
    rename!(stations, :name, :Label)
    writetable("$(data_path)/st_data_$(file)", stations)
end

data = readcsv(data_path*"/$(files[1])")
get_stations(data, st_info)
edges = map(Int64,readcsv(data_path*"/$(files[1])"))
edgest = map((x,y)-> tuple(x,y),tuple(edges[:,1], edges[:,2])...)

graph = DiGraph(get_adj_mat(edges))
