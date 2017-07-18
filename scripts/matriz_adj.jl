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
data = readcsv(data_path*"/"*files[1])[2:end, :]

###================###================###================###================###

m = 2
month_data = view(data, find(x->x==m, data[:,3]), 1:2)

trip = Dict()
# key = (id_start, id_end)
# val = # apariciones

for i in 1:size(month_data,1)
    val = (month_data[i, 1], month_data[i, 2])
    if month_data[i, 1] < 500 && month_data[i, 2] < 500 && month_data[i,1] != month_data[i,2]
        haskey(trip, val) == false ? trip[val] = 1 : trip[val] += 1
    end
end

id_start = [k[1] for k in keys(trip)]
id_end  = [k[2] for k in keys(trip)]

times_month = 2 #numero de veces que se usa (al menos en un mes)

vals = filter(x -> x >= times_month, collect(values(trip)))

# max_time_day = div(maximum(vals), 365)
# max_times_year = div(sum(collect(values(route))), 365) / 446

###================###================###================###================###

vals = collect(values(route))

histogram(vals, bins = range(minimum(vals)-0.5, maximum(vals)+1), xlims = (0,13), xticks = minimum(vals):maximum(vals), normed = true)

xlims!(0, 15)
xticks!(collect(1:11))

xlims!((365,maximum(vals)))

histogram(filter(x -> x >= threshold, vals), nbins = 50)
histogram(filter(x -> x >= threshold, vals), nbins = 50)

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
