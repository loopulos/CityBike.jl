function stat_net(d::SubArray{Any,2}, th::Int)
    trip = Dict()
    for i in 1:size(d,1)
        val = (d[i, 1], d[i, 2])
        if d[i, 1] < 500 && d[i, 2] < 500 && d[i,1] != d[i,2]
            haskey(trip, val) == false ? trip[val] = 1 : trip[val] += 1
        end
    end
    filter!((k,v) -> v > th, trip)
    i_st = [k[1] for k in keys(trip)]
    e_st = [k[2] for k in keys(trip)]
    norm_factor = sum(collect(values(trip)))
    adj_mat = sparse(i_st, e_st, collect(values(trip)) ./ norm_factor)
    #adj_mat = sparse(i_st, e_st, collect(values(trip)))
    return adj_mat
end
