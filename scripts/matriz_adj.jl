using Plots

gui()
gr()
pyplot()

data_path = "/$(homedir())/Google\ Drive/EcobiciDATA/EcobiciDF"
# data_path = "/$(homedir())/Google\ Drive/EcobiciDATA/EcobiciDF"

files = filter(x -> ismatch( r"filt_\d+.csv", x), readdir(data_path))

file = files[end]

data = readcsv(data_path*"/"*file)

route = Dict()

for i in 2:length(data[2:end, 1])
    if data[i, 1] < 500 && data[i, 2] < 500
        # key = (id_start, id_end)
        # val = # apariciones
        val = (data[i, 1], data[i, 2])
        haskey(route, val) == false ? route[val] = 1 : route[val] += 1
    end
end

id_start = [k[1] for k in keys(route)]
id_end  = [k[2] for k in keys(route)]

times_day = 2

test_line

vals = filter(x -> x >= lw_thr, collect(values(route)))

max_time_day = div(maximum(vals), 365)
max_times_year = div(sum(collect(values(route))), 365) / 446

histogram(vals, nbins = 50)
xlims!((365,maximum(vals)))


histogram(filter(x -> x >= threshold, vals), nbins = 50)

adj = spzeros(Float64, maximum(id_start), maximum(id_end))
adj = zeros(Float64, maximum(id_start), maximum(id_end))

norm_factor = sum(collect(values(route)))

for key in keys(route)
    adj[key[1], key[2]] = route[key] / norm_factor
end

histogram(reshape(adj, 1, length(adj)), nbins = 50)

out_vals_sort = Float64[out_stations[key] for key in out_keys_sort]
in_vals_sort  = Float64[in_stations[key] for key in in_keys_sort]

out_tot_counts = sum(Float64[val for val in values(out_stations)])
in_tot_counts  = sum(Float64[val for val in values(in_stations)])

println(out_tot_counts, "\t", in_tot_counts)

plt[:plot](out_keys_sort, out_vals_sort ./ out_tot_counts, ".-", label = "out_"*replace(split(data_path*"/"*file, ".")[1], "filt_", ""))
plt[:plot](in_keys_sort, in_vals_sort ./ in_tot_counts, ".-", label = "in_"*replace(split(data_path*"/"*file, ".")[1], "filt_", ""))

# end
