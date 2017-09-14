###########################################
function get_dict_st(st::Array{Any,2})
    dict_st = Dict()
    dict_st[0] = st[1,2:end] #aqui se pone el head
    for i = 2:size(st,1)
        dict_st[st[i,1]] = st[i,2:end]
    end
    return dict_st
end

###================###================###

function trip_dict(data)
    trip = Dict()

    if length(data) != 0.
        # key = (id_start, id_end)
        # val = # apariciones

        for i in 1:size(data,1)
            val = (data[i, 1], data[i, 2])
            if data[i, 1] < 500 && data[i, 2] < 500 && data[i,1] != data[i,2]
                haskey(trip, val) == false ? trip[val] = 1 : trip[val] += 1
            end
        end

    end

    return trip
end


###================###================###
# adyacencia dirigida
function get_adj_mat(trip, norm=false)

    i_st = [k[1] for k in keys(trip)]
    e_st = [k[2] for k in keys(trip)]

    adj_mat = sparse(i_st, e_st, collect(values(trip)))

    f_adj = zeros(Int, maximum(size(adj_mat)), maximum(size(adj_mat)))

    if norm == false
        for j in 1:size(adj_mat, 2)
            for i in rowvals(adj_mat)[nzrange(adj_mat, j)]
                f_adj[i,j] = 1
            end
        end
    else
        for j in 1:size(adj_mat, 2)
            for i in rowvals(adj_mat)[nzrange(adj_mat, j)]
                f_adj[i,j] = trip[i,j]
            end
        end
    end

    return f_adj
end
function get_adj_mat(stats, norm=false)

    i_st = stats[:,1]
    e_st = stats[:,2]

    adj_mat = sparse(i_st, e_st, maximum(stats))

    f_adj = zeros(Int, maximum(size(adj_mat)), maximum(size(adj_mat)))

    if norm == false
        for j in 1:size(adj_mat, 2)
            for i in rowvals(adj_mat)[nzrange(adj_mat, j)]
                f_adj[i,j] = 1
            end
        end
    else
        for j in 1:size(adj_mat, 2)
            for i in rowvals(adj_mat)[nzrange(adj_mat, j)]
                f_adj[i,j] = trip[i,j]
            end
        end
    end

    return f_adj
end

function get_stations(data, st_info)
    i_st = map(Int64, data[:,1])
    e_st = map(Int64, data[:,2])
    all_st = sort(unique(union(i_st,e_st)))
    stations = st_info[[find( x -> x == st, st_info[:id])[1] for st in all_st], [:id, :name,:location_lat, :location_lon] ]
    rename!(stations, :id, :Id)
    rename!(stations, :name, :Label)
    return stations
end
###================###================###
###  Algoritmo de Clustering Recursivo   ###
###================###================###

# funcion de asignacion de "etiqueta" para clustering recursivo

function set_label(U, i, c, label, cl_size)

	n = size(U[i],1)

	if n != 0

		# println(n)

		for j in 1:n
			k = U[i][j]

			if get(label, k, 0) == 0
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

	label = Dict{Int64,Int64}()
	cl_size = Dict{Int64,Int64}()

	for i in 1:n

		if get(label, i, 0) == 0

			cl_size[c] = 1
			label[i] = c
			set_label(neigh,i,c,label,cl_size)

		end

		c += 1

	end

	return cl_size, label

end

###================###================###
# calcula clusters del diccionario "trip" con el umbral "th"
function clusters_th(trip, th)

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

    return cl, lab
end

###================###================###

# calcula clusters del diccionario "trip"
function clusters(trip)

    i_st = [k[1] for k in keys(trip)]
    e_st = [k[2] for k in keys(trip)]

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
        neigh[i] = [k[2] for k in collect(keys(filter((k,v) -> k[1] == i, trip)))]
    end

    cl, lab = cluster_n_label(neigh)

    return cl, lab
end

###================###================###

function make_dir_from_path(path)

    try
        mkdir(path)
    catch error
        println("Folder already exists")
    end

end
