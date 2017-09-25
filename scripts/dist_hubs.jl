using Plots, LightGraphs
include("funcs.jl")

data_path = "/home/alfredo/Ecobici/Filt/csv_data/Buenos" #Aqui estan los archivos que escogi de las redes, los subi al drive.
files = readdir(data_path)


for f in files
    data = map(Int64,readcsv(data_path*"/$f")[2:end,1:2])

    get_adj_mat(data)

    g = DiGraph(get_adj_mat(data))
    gd = degree(g)
    ind = [i for i in 1:length(gd)]
    hubs = sortrows([ind gd], by = x -> (x[2]), rev = true)
    println(hubs[1:20])

end
