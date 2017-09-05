
# using Plots, LightGraphs, DataFrames
# using Plots, DataFrames
# using LightGraphs
using DataFrames

###================###================###================###================###

include("$(homedir())/GitRepos/CityBike.jl/scripts/funcs.jl")
# include("funcs.jl")
# histogram(collect(values(trip)))

data_path = "$(homedir())/Google\ Drive/EcobiciDATA/EcobiciDF"
# data_path = "$(homedir())/Ecobici"

# output_path = data_path*"/Graphs/threshold"
output_path = data_path*"/csv_data"

fig_path = data_path*"/perc_year"
# fig_path = data_path*"/perc_month"

files = filter(x -> ismatch(r"^filt_.", x), readdir(data_path))
years = [match(r"(\w+_\d+||\w+_\d+-\w+)\.\w+$", f).captures[1] for f in files]

###=============###================###================###================###

j = 2

data = readcsv(data_path*"/"*files[2])[2:end, :]
trip = trip_dict(data)

# th_vals = linspace(minimum(collect(values(trip))),maximum(collect(values(trip))), 25)
# cl_sizes = zeros(length(th_vals))
# max_st = zeros(Int, length(th_vals))

# labels = Dict()

# cl, lab = clusters_th(trip, th_vals[i])
# cl, lab = clusters(trip)

# cl_sizes[i] = maximum(collect(values(cl)))

# labels[i] = lab

i_st = [k[1] for k in keys(trip)]
e_st = [k[2] for k in keys(trip)]

# max_st = maximum(unique(union(i_st,e_st)))
all_st = sort(unique(union(i_st,e_st)))

### WEIGHTED LINKS
writetable("$(output_path)/$(years[j])_adj_anual_weight.csv",
            DataFrame( Source = i_st, Target = e_st, Weight = collect(values(trip)) ./ sum(collect(values(trip))) ))

### JUST LINKS
writetable("$(output_path)/$(years[j])_adj_anual.csv",
            DataFrame( Source = i_st, Target = e_st ))

###================###================###================###================###

st_info = readtable(data_path*"/estacionesn.csv")

stations = st_info[[find( x -> x == st, st_info[:id])[1] for st in all_st], [:id, :name,:location_lat, :location_lon] ]

rename!(stations, :id, :Id)
rename!(stations, :name, :Label)

# writetable("$(output_path)/st_data_$(years[j])_m_$(m)_th_$(i).csv", sort(stations, cols = (:Id)))
writetable("$(output_path)/st_data_$(years[j]).csv", stations)

###================###================###================###================###
