###================###================###================###================###
###  GENERA MATRICES DE ADYACENCIA POR MES
###================###================###================###================###

# funcion de asignacion de "etiqueta" para clustering recursivo

function set_label(U, i, c, label, cl_size)

	n = size(U[i],1)

	if n != 0

		# println(n)

		for j in 1:n
			k = U[i][j]

			if label[k] == 0
				label[k] = label[i]
                cl_size[label[i]] += 1
				set_label(U,k,c,label,cl_size)
			end
		end
	end

end

###========================================###

# Algoritmo de clustering recursivo

function cluster(neigh)

	c = 1 # etiqueta cluster inicial
	n = size(neigh,1)

	label = zeros(Int64,n)
	cl_size = Dict{Int64,Int64}()

	for i in 1:n

		if label[i] == 0

			cl_size[c] = 1
			label[i] = c
			set_label(neigh,i,c,label,cl_size)

		end

		c += 1

	end

	return cl_size

end

###========================================###

function cluster_n_label(neigh)

	c = 1 # etiqueta cluster inicial
	n = size(neigh,1)

	label = zeros(Int64,n)
	cl_size = Dict{Int64,Int64}()

	for i in 1:n

		if label[i] == 0

			cl_size[c] = 1
			label[i] = c
			set_label(neigh,i,c,label,cl_size)

		end

		c += 1

	end

	return cl_size, label

end

###================###================###================###================###

using Plots, LightGraphs

gui()
gr()
pyplot()

###================###================###================###================###

data_path = "/$(homedir())/Google\ Drive/EcobiciDATA/EcobiciDF"
data_path = "/$(homedir())/Ecobici"

files = filter(x -> ismatch( r"filt_\d+.csv", x), readdir(data_path))

# mes es la columna 3
data = readcsv(data_path*"/"*files[6])[2:end, :]

###================###================###================###================##

m = 12
# for m in 1:12

print(m)

trip = Dict()

month_data = view(data, find(x -> x == m, data[:,3]), 1:2)

month_data = data

if length(month_data) != 0.
    # key = (id_start, id_end)
    # val = # apariciones

    for i in 1:size(month_data,1)
        val = (month_data[i, 1], month_data[i, 2])
        if month_data[i, 1] < 500 && month_data[i, 2] < 500 && month_data[i,1] != month_data[i,2]
            haskey(trip, val) == false ? trip[val] = 1 : trip[val] += 1
        end
    end

end

###================###================###================###================###

histogram(collect(values(trip)))

###================###================###================###================###
# Genera matriz de adyacencia (sparse)

th_vals = linspace(minimum(collect(values(trip))),maximum(collect(values(trip))), 25)

cl_sizes = zeros(length(th_vals))
k = 1

for th in th_vals
    filt_trip = filter((k,v) -> v >= th, trip)

    i_st = [k[1] for k in keys(filt_trip)]
    e_st = [k[2] for k in keys(filt_trip)]

    # todas las estaciones posibles
    all_st = unique(union(i_st,e_st))

    # diccionario con las vecindades de cada nodo
    # llave -> id_st
    # valor -> [id_st]
    neigh = Array{Array{Int,1},1}(maximum(all_st))

    for i in 1:length(neigh)
        neigh[i] = Int[]
    end

    for i in all_st
        neigh[i] = [k[2] for k in collect(keys(filter((k,v) -> k[1] == i, filt_trip)))]
    end


    cl, lab = cluster_n_label(neigh)

    cl_sizes[k] = maximum(collect(values(cl)))

    k += 1

end

i_st = [k[1] for k in keys(trip)]
e_st = [k[2] for k in keys(trip)]

# todas las estaciones posibles
all_st = maximum(unique(union(i_st,e_st)))

plot(collect(th_vals)./30 , cl_sizes ./ all_st, m = :o, leg = false, xticks = collect(0:100))

plot(collect(th_vals) , cl_sizes ./ all_st, m = :o, leg = false)
plot(collect(th_vals)./365 , cl_sizes ./ all_st, m = :o, leg = false)

# histogram()

gui()

# umbral de "percolacion"
th = ceil(th_vals[5])

###================###================###================###================###

filt_trip = filter((k,v) -> v >= th, trip)

i_st = [k[1] for k in keys(filt_trip)]
e_st = [k[2] for k in keys(filt_trip)]

# norm_factor = sum(collect(values(filt_trip)))

adj_mat = sparse(i_st, e_st, collect(values(filt_trip)))
# adj_mat = sparse(i_st, e_st, collect(values(trip)) ./ norm_factor)

deg_in = zeros(Int, size(adj_mat, 2))
deg_out = zeros(Int, size(adj_mat, 1))

for j in 1:size(adj_mat, 2)
    deg_in[j] = length(nzrange(adj_mat, j))
    # println(j, "\t", deg_in, "\t", deg_out, "\t", deg_in == deg_out, "\t", deg_out - deg_in)
end

for j in 1:size(adj_mat, 1)
    deg_out[j] = length(nzrange(transpose(adj_mat), j))
    # println(j, "\t", deg_in, "\t", deg_out, "\t", deg_in == deg_out, "\t", deg_out - deg_in)
end

histogram(deg_out)

plot(sort(deg_in, rev=true), ylims = (1, maximum(deg_in)), yscale=:log10, xscale = :log10 , m = :o)

scatter!(graph, sort([deg_in[i] for i in findn(deg_in)], rev = true), yscale=:log10, xscale = :log10)
scatter!(graph, sort(deg_in, rev = true), ylims = (1, maximum(deg_in)), yscale=:log10, xscale = :log10, legend = :bottomleft)
histogram!(graph, deg_in, alpha = 0.3, legend = :bottomleft)
histogram!(graph, filter(x -> x >= th, collect(values(trip))), alpha = 0.3, legend = :topright, norm = true)

gui()

###================###================###================###================###

f_adj = zeros(Int, size(adj_mat,2), size(adj_mat,2))
# f_adj = zeros(Int, size(adj_mat))

for j in 1:size(adj_mat, 2)
    for i in rowvals(adj_mat)[nzrange(adj_mat, j)]
        f_adj[i,j] = 1
    end
end

network = DiGraph(f_adj)

deg_h = degree_histogram(network, indegree)

scatter(collect(keys(deg_h)), collect(values(deg_h)), m = :o,  xscale = :log10, yscale = :log10, xlims = (1, maximum(collect(keys(deg_h)))), ylims = (1, maximum(collect(values(deg_h)))), label = "in")

deg_h = degree_histogram(network, outdegree)

scatter!(collect(keys(deg_h)), collect(values(deg_h)), m = :o,  xscale = :log10, yscale = :log10, xlims = (1, maximum(collect(keys(deg_h)))), ylims = (1, maximum(collect(values(deg_h)))), label = "out")

gui()
