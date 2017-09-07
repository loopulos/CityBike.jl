
# using Plots, LightGraphs, DataFrames

# using LightGraphs
#using GraphPlot
#using Compose
# using DataFrames
using Plots, DataFrames

include("$(homedir())/GitRepos/CityBike.jl/scripts/funcs.jl")
# include("funcs.jl")
# histogram(collect(values(trip)))

data_path = "$(homedir())/Google\ Drive/EcobiciDATA/EcobiciDF"

output_path = data_path*"/Graphs/threshold"
output_path = data_path*"/csv_data"

# fig_path = data_path*"/perc_month"
fig_path = data_path*"/perc_year"

files = filter(x -> ismatch(r"^filt_.", x), readdir(data_path))
years = [match(r"(\w+_\d+||\w+_\d+-\w+)\.\w+$", f).captures[1] for f in files]
# years = [match(r"(\d+)$", i).captures[1] for i in [match(r"^(\w+_\d+)", f).captures[1] for f in files]]

###=============###================###================###================###
<<<<<<< HEAD
j = 2

data = readcsv(data_path*"/"*files[j])[2:end, :]

trip = trip_dict(data) # acumulado anual


m = 2
=======

j = 3
println(files[j])

output_path = data_path*"/$(years[j])"

make_dir_from_path(output_path)
make_dir_from_path(output_path*"/adj_month")
make_dir_from_path(output_path*"/cl_dist")

data = readcsv(data_path*"/"*files[j])[2:end, :]

st_info = readtable(data_path*"/estacionesn.csv")
>>>>>>> master

###=============###================###================###================###

all_th_vals = zeros(30, 12)

# m = 1
for m in 1:12

    println("m: ", m)
    make_dir_from_path(output_path*"/adj_month/$(m)")
    make_dir_from_path(output_path*"/cl_dist/$(m)")

    # filter by month (column 3)
    if length(find(x -> x == m, data[:, 3])) != zero(Int)
        month_data = data[find(x -> x == m, data[:, 3]), :]
        trip = trip_dict(month_data)
    end

    th_vals = linspace(minimum(collect(values(trip))),maximum(collect(values(trip))), 30)

    all_th_vals[:, m] = th_vals

    cl_sizes = Dict()
    labels = Dict()

    for i in 1:length(th_vals)

        println("th: ", i)

        filt_trip = filter((k,v) -> v >= th_vals[i], trip)

        cl_sizes[i], labels[i] = clusters_th(filt_trip, th_vals[i])

        i_st = [k[1] for k in keys(filt_trip)]
        e_st = [k[2] for k in keys(filt_trip)]

        all_st = sort(unique(union(i_st,e_st)))

        ### WEIGHTED LINKS
        writetable("$(output_path)/adj_month/$(m)/$(years[j])_adj_th_$(i)_m_$(m)_weight.csv",
                    DataFrame( Source = i_st, Target = e_st, Weight = collect(values(filt_trip)) ./ sum(collect(values(filt_trip))) ))

        # ### JUST LINKS
        # writetable("$(output_path)/adj_month/$(m)/$(years[j])_adj_th_$(i)_m_$(m).csv",
        #             DataFrame( Source = i_st, Target = e_st ))

        s_cl = sort(collect(cl_sizes[i]), by=x->x[2], rev = true)

        # bar(collect(1:length(s_cl)), [x[2] for x in s_cl] ./ sum([x[2] for x in s_cl]), bar_position = :stack)
        plot(collect(1:length(s_cl)), [x[2] for x in s_cl] ./ sum([x[2] for x in s_cl]), m = :o)

        png("$(output_path)/cl_dist/$(m)/cl_dist_th_$(i)")

    end

end

writecsv("$(output_path)/all_th_vals.csv", all_th_vals)

###================###================###================###================###
stations = st_info[[find( x -> x == st, st_info[:id])[1] for st in all_st], [:id, :name,:location_lat, :location_lon] ]

rename!(stations, :id, :Id)
rename!(stations, :name, :Label)

writetable("$(output_path)/st_data_$(years[j])_m_$(m)_th_$(i).csv", sort(stations, cols = (:Id)))

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

    println(i)
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

###================###================###================###================###

cl_sizes[10]

for k in sort(collect(keys(cl_sizes[10])))
    println(k," ", cl_sizes[10][k])
end

hcat(sort(collect(keys(cl_sizes[10]))), collect(1:length(keys(cl_sizes[10]))), [cl_sizes[10][i] for i in sort(collect(keys(cl_sizes[10])))] )

sort(collect(values(cl_sizes[10])), rev=true)

i = 1

hcat(collect(1:length(values(cl_sizes[i]))), sort(collect(values(cl_sizes[i])), rev=true) ./ sum(collect(values(cl_sizes[i]))))

# for i in 1:length(th_vals)
for i in sort(collect(keys(cl_sizes[10])))

    println(sort(collect(values(cl_sizes[i])), rev=true) ./ sum(collect(values(cl_sizes[i]))))
end

###================###================###================###================###

pyplot()

make_dir_from_path("$(output_path)/cl_dist/$(m)")

for i in 1:length(th_vals)
    println(i)
    s_cl = sort(collect(cl_sizes[i]), by=x->x[2], rev = true)

    bar(collect(1:length(s_cl)), [x[2] for x in s_cl] ./ sum([x[2] for x in s_cl]), bar_position = :stack)

    png("$(output_path)/cl_dist/$(m)/cl_dist_th_$(i)")
end
