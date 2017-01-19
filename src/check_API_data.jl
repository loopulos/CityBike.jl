using StatPlots, DataFrames

function get_day_hour(tr_date)

    hour = parse(Int,match(r".(\d+):\d+:\d+", lstrip(split(tr_date, ',')[2])).captures[1])
    day = rstrip(split(tr_date, ' ')[1], ',')

    return (day, hour)
end

### ========================================== ###

gui()

data_folder = "$(homedir())/Downloads/BiciUso"

all_files = readdir(data_folder)

day_hour = transpose(hcat([match(r".(\d+)T(\d+):.", file).captures for file in files]...))


data = readtable(string(data_folder,"/",files[1]),separator='\t')

find(x -> x == unique(d[:,1])[2], d[:,1])

### ========================================== ###

# graffica de distancia contra tiempo para cada modalidad
scatter(data, [:driving_dist, :bike_dist, :transit_dist],
    [:driving_time, :bike_time, :transit_time],
    xlabel = "distance",
    ylabel = "time")




scatter(data, [:driving_dist, :bike_dist, :transit_dist])

tr_ids = Dict()

for i in 1:size(data, 1)
    println((data[:start_id][i], data[:end_id][i]))
end

groupedbar(hcat([data[:bike_dist], data[:driving_dist], data[:transit_time]]...),
    bar_position = :stack)

plot(collect(1:length(data[:date])), hcat([data[:bike_dist], data[:driving_dist], data[:transit_dist]]...), marker = :o)

plot(collect(1:length(data[:date])), mean(hcat([data[:bike_dist], data[:driving_dist], data[:transit_dist]]...), 2), marker = :o)

plot(collect(1:length(data[:date])), hcat([data[:bike_dist], data[:driving_dist], data[:transit_time]]...))
