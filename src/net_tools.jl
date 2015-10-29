###==========================###==========================###
### TOOLS FOR CONSTRUCT AND MANIPULATE NETWORKS
###==========================###==========================###

# Funcion para calcular distancias entre coordenadas

function calc_dist(lat1::Float64, long1::Float64, lat2::Float64, long2::Float64)

    R = 6371.0 # radio tierra kilimetros
    phi1 = deg2rad(lat1)
    phi2 = deg2rad(lat2)

    deltaPhi  = deg2rad(lat2-lat1)
    deltaLong = deg2rad(long2-long1)

    a = sin(deltaPhi/2.0) * sin(deltaPhi/2.0) + cos(phi1) * cos(phi2) * sin(deltaLong/2.0) * sin(deltaLong/2.0)

    c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a))

    d = R * c

    return d
end

###==========================###==========================###
#La funcion construye la matriz geometrica a partir de una
#lista de coordenadas de las estaciones
function cons_mdist(estaciones::Array{Float64,2})
    N = size(estaciones,1)
    mat_dist = zeros(Float64,(N,N))
    k = 1
    for i = 1:N, j = i:N #corre el arreglo sin repetir
        dist = calc_dist(estaciones[i,2],estaciones[i,3],estaciones[j,2],estaciones[j,3])
        mat_dist[i,j] = mat_dist[j,i] = dist #recordar que la matriz es simetrica
    end
    return mat_dist
end
###==========================###==========================###
#La funcion construye vector con distancias entre estaciones
#de una lista de coordenadas de las estaciones
function cons_vdist(estaciones::Array{Float64,2})
    N = size(estaciones,1)
    vec_dist = zeros(Float64,div(N*(N-1),2))
    k = 1
    for i = 1:N, j = i:N #corre el arreglo sin repetir
        dist = calc_dist(estaciones[i,2],estaciones[i,3],estaciones[j,2],estaciones[j,3])
        vec_dist[k] = dist
        k += 1
    end
    return vec_dist
end
###==========================###==========================###
