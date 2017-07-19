###================###================###================###================###
###  GENERA MATRICES DE ADYACENCIA POR MES
###================###================###================###================###

using Plots

gui()
gr()
pyplot()

###================###================###================###================###

data_path = "/$(homedir())/Google\ Drive/EcobiciDATA/EcobiciDF"
data_path = "/$(homedir())/Ecobici"

files = filter(x -> ismatch( r"filt_\d+.csv", x), readdir(data_path))

# mes es la columna 3
data = readcsv(data_path*"/"*files[6])[2:end, :]

###================###================###================###================###

m = 10
# anim = @animate for m in 2:12
# for m in 2:12
    # print(m)

trip = Dict()

month_data = view(data, find(x -> x == m, data[:,3]), 1:2)

if length(month_data) != 0.
    # key = (id_start, id_end)
    # val = # apariciones

    for i in 1:size(month_data,1)
        val = (month_data[i, 1], month_data[i, 2])
        if month_data[i, 1] < 500 && month_data[i, 2] < 500 && month_data[i,1] != month_data[i,2]
            haskey(trip, val) == false ? trip[val] = 1 : trip[val] += 1
        end
    end

    # vals = extrema(unique(collect(values(trip))))
    # println(m, "\t", extrema(unique(collect(values(trip)))), "\t", sum(collect(values(trip))))

    # histogram(vals, bins = range(minimum(vals)-0.5, maximum(vals)+1), xlims = (0,maximum(vals)+4), xticks = minimum(vals):maximum(vals), normed = true)
end

# end

i_st = [repr(collect(keys(trip))[i][1]) for i in 1:length(collect(keys(trip)))]
e_st = [repr(collect(keys(trip))[i][2]) for i in 1:length(collect(keys(trip)))]

heatmap(i_st, e_st, transpose(collect(values(trip))), aspect_ratio = 1)

sorted_vals = sort(collect(trip), by = tuple -> last(tuple), rev = true)
sorted_vals[1][2]

filt_sorted_vals = filter(x -> x[2] > 14, sorted_vals)

bar([ repr(val[1]) for val in filt_sorted_vals], [ val[2] for val in filt_sorted_vals])

bar(collect(1:length(sorted_vals)), [ val[2] for val in sorted_vals], xscale = :log10, yscale = :log10)

scatter(collect(1:length(sorted_vals)), [ val[2] for val in sorted_vals], yscale = :log10, xlims = (1, length(sorted_vals)))

scatter(collect(1:length(sorted_vals)), [ val[2] for val in sorted_vals], xscale = :log10, yscale = :log10, xlims = (1, length(sorted_vals)))

gui()

gif(anim, "distros.gif", fps = 2)
###================###================###================###================###

# histogram(filter(x -> x >= threshold, vals), nbins = 50)

id_start = [k[1] for k in keys(trip)]
id_end  = [k[2] for k in keys(trip)]

times_month = 2 #numero de veces que se usa (al menos en un mes)

#vals = filter(x -> x >= times_month, collect(values(trip)))

# max_time_day = div(maximum(vals), 365)
# max_times_year = div(sum(collect(values(route))), 365) / 446

###================###================###================###================###

adj = spzeros(Float64, maximum(id_start), maximum(id_end))
adj = zeros(Float64, maximum(id_start), maximum(id_end))

norm_factor = sum(collect(values(route)))

for key in keys(route)
    adj[key[1], key[2]] = route[key] / norm_factor
end

histogram(reshape(adj, 1, length(adj)), nbins = 50)

###================###================###================###================###

out_vals_sort = Float64[out_stations[key] for key in out_keys_sort]
in_vals_sort  = Float64[in_stations[key] for key in in_keys_sort]

out_tot_counts = sum(Float64[val for val in values(out_stations)])
in_tot_counts  = sum(Float64[val for val in values(in_stations)])

println(out_tot_counts, "\t", in_tot_counts)

###================###================###================###================###

plt[:plot](out_keys_sort, out_vals_sort ./ out_tot_counts, ".-", label = "out_"*replace(split(data_path*"/"*file, ".")[1], "filt_", ""))
plt[:plot](in_keys_sort, in_vals_sort ./ in_tot_counts, ".-", label = "in_"*replace(split(data_path*"/"*file, ".")[1], "filt_", ""))

# end
