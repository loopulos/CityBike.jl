
# using Plots, LightGraphs, DataFrames
# using Plots, DataFrames
# using LightGraphs
using DataFrames, Plots

###================###================###================###================###

include("$(homedir())/GitRepos/CityBike.jl/scripts/funcs.jl")
include("funcs.jl")
# histogram(collect(values(trip)))

data_path = "$(homedir())/Google\ Drive/EcobiciDATA/EcobiciDF"
data_path = "/media/alfredo/Killer-Rabbit1.5/Ecobicis/CDMX/Filt"
data_path = "$(homedir())/Ecobici/Filt"

# output_path = data_path*"/Graphs/threshold"
output_path = data_path*"/csv_data/2015/2-12"

fig_path = data_path*"/perc_year"
# fig_path = data_path*"/perc_month"

files = filter(x -> ismatch(r"^filt_.", x), readdir(data_path))
years = [match(r"(\w+_\d+||\w+_\d+-\w+)\.\w+$", f).captures[1] for f in files]

###=============###================###================###================###

j = 6
ms = [2,3,4,5,6,7,8,9,10,11,12]
data = readcsv(data_path*"/"*files[j])[2:end, :]
m = 1

if length(findin(data[:, 3], ms)) != zero(Int) #for cummulative, use findin()
    month_data = data[findin(data[:, 3],ms), :]
    trip = trip_dict(month_data)
end

if length(find(x -> x == m, data[:, 3])) != zero(Int) #for cummulative, use findin()
    month_data = data[find(x -> x == m, data[:, 3]), :]
    trip = trip_dict(month_data)
end
#trip = trip_dict(data)

i_st = [k[1] for k in keys(trip)]
e_st = [k[2] for k in keys(trip)]

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
writetable("$(output_path)/st_data_2015-212.csv", stations)

###================###================###================###================###

th_vals = linspace(minimum(collect(values(trip))),maximum(collect(values(trip))), 30)
# max_st = zeros(Int, length(th_vals))

# cl_sizes = zeros(length(th_vals))
cl_sizes = Dict()
labels = Dict()

for i in 1:length(th_vals)
    println(i)

    filt_trip = filter((k,v) -> v >= th_vals[i], trip)

    # cl, lab = clusters_th(filt_trip, th_vals[i])
    # cl_sizes[i] = maximum(collect(values(cl)))
    # labels[i] = lab

    cl_sizes[i], labels[i] = clusters_th(filt_trip, th_vals[i])

    i_st = [k[1] for k in keys(filt_trip)]
    e_st = [k[2] for k in keys(filt_trip)]

    all_st = sort(unique(union(i_st,e_st)))

    ### WEIGHTED LINKS
    writetable("$(output_path)/$(years[j])_th_$(i)_adj_2015-212_weight.csv",
                DataFrame( Source = i_st, Target = e_st, Weight = collect(values(filt_trip)) ./ sum(collect(values(filt_trip))) ))

    ### JUST LINKS
    writetable("$(output_path)/$(years[j])_th_2015-212_adj_anual.csv",
                DataFrame( Source = i_st, Target = e_st ))

end

pyplot()
gui()

make_dir_from_path("$(output_path)/cl_dist/")

for i in 1:length(th_vals)
    println(i)
    s_cl = sort(collect(cl_sizes[i]), by=x->x[2], rev = true)

    bar(collect(1:length(s_cl)), [x[2] for x in s_cl] ./ sum([x[2] for x in s_cl]), bar_position = :stack)

    png("$(output_path)/cl_dist/cl_dist_th_$(i)")
end

size_hist = plot()

# for k in sort(collect(keys(cl_sizes)))
for k in sort(collect(keys(cl_sizes)))
    # histogram!(size_hist, collect(values(cl_sizes[k])), alpha = 0.5, norm = true, leg = false)
    histogram(collect(values(cl_sizes[k])), alpha = 0.5, leg = false)
    png(output_path*"/$(k)")
end

size_hist

plot(th_vals, [maximum(collect(values(cl_sizes[k]))) for k in sort(collect(keys(cl_sizes)))], m = :o)
png(output_path*"/clusters_th")

histogram(collect(values(cl_sizes[10])), alpha = 0.5, norm = true)
###================###================###================###================###
