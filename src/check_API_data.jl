using StatPlots
using DataFrames

function get_day_hour(tr_date)

    hour = parse(Int,match(r".(\d+):\d+:\d+", lstrip(split(tr_date, ',')[2])).captures[1])
    day = rstrip(split(tr_date, ' ')[1], ',')

    return (day, hour)
end

### ========================================== ###

n_travs = 300

data_folder = "$(homedir())/Downloads/BiciUso"

all_files = readdir(data_folder)

day_hour = transpose(hcat([broadcast(x -> parse(Int,x), match(r".(\d+)T(\d+):.", file).captures) for file in all_files]...))

days = unique(day_hour[:,1])

# i = 1
for i in 1:length(days)

    println(days[i])

    hours = find(x -> x == days[i], day_hour[:,1])

    bike_data_per_day    = zeros(n_travs, length(hours))
    transit_data_per_day = zeros(n_travs, length(hours))
    driving_data_per_day = zeros(n_travs, length(hours))

    ### ========================================== ###

    # data = readtable(string(data_folder, "/", all_files[1]), separator = '\t')

    # j = 1
    for j in 1:length(hours)

        println(all_files[hours[j]])

        data = readtable(string(data_folder, "/", all_files[hours[j]]), separator = '\t')

        bike_data_per_day[:,j]    = data[:bike_time]
        transit_data_per_day[:,j] = data[:transit_time]
        driving_data_per_day[:,j] = data[:driving_time]

        # bike_data_per_day[:,j]    = data[:bike_dist]
        # transit_data_per_day[:,j] = data[:transit_dist]
        # driving_data_per_day[:,j] = data[:driving_dist]
    end

    ### ========================================== ###

    bike_plt = plot(transpose(bike_data_per_day),
        leg = false,
        marker = :o,
        markersize = 2.5,
        # line = :dash,
        linealpha = 0.8,
        title = "bike",
        xlabel = "hora",
        ylabel = "tiempo en seg")

    transit_plt = plot(transpose(transit_data_per_day),
        leg = false,
        marker = :o,
        markersize = 2.5,
        # line = :dash,
        linealpha = 0.8,
        title = "transit",
        # ylabel = "tiempo en seg",
        xlabel = "hora")

    driving_plt = plot(transpose(driving_data_per_day),
        leg = false,
        marker = :o,
        markersize = 2.5,
        # line = :dash,
        linealpha = 0.8,
        title = "driving",
        # ylabel = "tiempo en seg",
        xlabel = "hora")

    plot(bike_plt, transit_plt, driving_plt,
        layout = @layout([bike_plt transit_plt driving_plt]),
        size = [1024, 400])

    # gui()

    savefig("$(homedir())/Google\ Drive/EcoBiciDATA/figs/tiempo_viaje_hr_dia_$(days[i]).png")

end
### ========================================== ###
### ========================================== ###

for i in 1:length(days)

    println(days[i])

    hours = find(x -> x == days[i], day_hour[:,1])

    bike_data_per_day    = zeros(n_travs, length(hours))
    transit_data_per_day = zeros(n_travs, length(hours))
    driving_data_per_day = zeros(n_travs, length(hours))

    ### ========================================== ###

    data = readtable(string(data_folder, "/", all_files[hours[1]]), separator = '\t')

    # grafica de distancia contra tiempo para cada modalidad
    scatter(data, [:driving_dist, :bike_dist, :transit_dist],
        [:driving_time, :bike_time, :transit_time],
        xlabel = "distance",
        ylabel = "time",
        lab = ["driving" "bike" "transit"])

    savefig("$(homedir())/Google\ Drive/EcoBiciDATA/EcoBiciDF/figs_google/distancia_tiempo_dia_$(days[i]).png")


end

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

### ========================================== ###
### ========================================== ###
