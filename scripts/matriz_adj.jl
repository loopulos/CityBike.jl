###================###================###================###================###
###  GENERA MATRICES DE ADYACENCIA POR MES
###================###================###================###================###

using Plots
include("funcs.jl")
#gui()
#gr()
pyplot()

###================###================###================###================###

#data_path = "/$(homedir())/Google\ Drive/EcobiciDATA/EcobiciDF"
data_path = "/$(homedir())/Ecobici"

files = filter(x -> ismatch( r"filt_\d+.csv", x), readdir(data_path))

# mes es la columna 3
data = readcsv(data_path*"/"*files[6])[2:end, :]
st = readcsv(data_path*"/estacionesn.csv")
###================###================###================###================###

dict_st = get_dict_st(st)

m = 2

ths = (15,30,60,120,240)

graph = plot()
month_data = view(data, find(x -> x == m, data[:,3]), 1:2)
# anim = @animate for m in 2:12
# for m in 1:6
for th in ths
    print(th)

    #trip = Dict()

#    month_data = view(data, find(x -> x == m, data[:,3]), 1:2)
    adj_mat = stat_net(month_data,th) #calcula la matriz de adyacencia con un valor umbral.
    deg_in = zeros(Int, size(adj_mat, 2))
    deg_out = zeros(Int, size(adj_mat, 1))
    for j in 1:size(adj_mat, 2)
        deg_in[j] = length(nzrange(adj_mat, j))
        deg_out[j] = length(nzrange(transpose(adj_mat), j))
         # println(j, "\t", deg_in, "\t", deg_out, "\t", deg_in == deg_out, "\t", deg_out - deg_in)
    end
    scatter!(graph,filter(x-> x > 0, sort(deg_in, rev = true)),  yscale=:log10, xscale = :log10, legend = :bottomleft)
end

gui()
    # if length(month_data) != 0.
    #     # key = (id_start, id_end)
    #     # val = # apariciones
    #
    #     for i in 1:size(month_data,1)
    #         val = (month_data[i, 1], month_data[i, 2])
    #         if month_data[i, 1] < 500 && month_data[i, 2] < 500 && month_data[i,1] != month_data[i,2]
    #             haskey(trip, val) == false ? trip[val] = 1 : trip[val] += 1
    #         end
    #     end
    #
    #     # vals = extrema(unique(collect(values(trip))))
    #     # println(m, "\t", extrema(unique(collect(values(trip)))), "\t", sum(collect(values(trip))))
    #
    #     # histogram(vals, bins = range(minimum(vals)-0.5, maximum(vals)+1), xlims = (0,maximum(vals)+4), xticks = minimum(vals):maximum(vals), normed = true)
    # end

    # end
###================###================###================###================###
    # Genera matriz de adyacencia (sparse)

    # i_st = [k[1] for k in keys(trip)]
    # e_st = [k[2] for k in keys(trip)]
    #
    # # norm_factor = sum(collect(values(trip)))
    #
    # adj_mat = sparse(i_st, e_st, collect(values(trip)))
    # # adj_mat = sparse(i_st, e_st, collect(values(trip)) ./ norm_factor)
    #
    # deg_in = zeros(Int, size(adj_mat, 2))
    # deg_out = zeros(Int, size(adj_mat, 1))
    #
    # for j in 1:size(adj_mat, 2)
    #     deg_in[j] = length(nzrange(adj_mat, j))
    #     deg_out[j] = length(nzrange(transpose(adj_mat), j))
    #     # println(j, "\t", deg_in, "\t", deg_out, "\t", deg_in == deg_out, "\t", deg_out - deg_in)
    # end

    # scatter(sort(deg_in, rev=true), ylims=(8,maximum(deg_in)), yscale=:log10)

    # scatter!(graph, sort([deg_in[i] for i in findn(deg_in)], rev = true), yscale=:log10, xscale = :log10)
    # scatter!(graph, sort(deg_in, rev = true), ylims = (1, maximum(deg_in)), yscale=:log10, xscale = :log10, legend = :bottomleft)
    # histogram!(graph, deg_in, alpha = 0.3, legend = :bottomleft)
    #histogram!(graph, filter(x -> x >= th, collect(values(trip))), alpha = 0.3, legend = :topright, norm = true)

#end


histogram(deg_in, alpha =0.5, label="Entrada", legendfont=font(15))
histogram!(deg_out, alpha = 0.5, label="Salida")
gui()
###================###================###================###================###
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
