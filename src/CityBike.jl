# Paquete del proyecto de ecobicis
# en colaboracion con el martin

module CityBike


###==========================###==========================###

# Fucncion para calcular distancias entre coordenadas

function calc_dist(lat1::Float64, long1::Float64, lat2::Float64, long2::Float64)

    R = 6371.0 # radio tierra kilimetros
    phi1 = radians(lat1)
    phi2 = radians(lat2)

    deltaPhi  = radians(lat2-lat1)
    deltaLong = radians(long2-long1)

    a = sin(deltaPhi/2.0) * sin(deltaPhi/2.0) + cos(phi1) * cos(phi2) * sin(deltaLong/2.0) * sin(deltaLong/2.0)

    c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a))

    d = R * c

    return d
end

###==========================###==========================###

end
