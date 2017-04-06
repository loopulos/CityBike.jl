using  Plots, DataFrames

### ========================================== ###

function get_day_hour(tr_date)

    hour = parse(Int,match(r".(\d+):\d+:\d+", lstrip(split(tr_date, ',')[2])).captures[1])
    day = rstrip(split(tr_date, ' ')[1], ',')

    return (day, hour)
end

### ========================================== ###

n_travs = 300

google_folder = "$(homedir())/Downloads/BiciUso"
ecobici_folder = "$(homedir())/Google\ Drive/EcoBiciDATA/EcoBiciDF"

google_files  = readdir(google_folder)
# ecobici_files = filter(x -> ismatch(r"filt_\d+.csv", x), readdir(ecobici_folder))

ecobici_files = filter(x -> ismatch(r"^\d{4}.csv", x), readdir(ecobici_folder)) # raw_data

day_hour = transpose(hcat([broadcast(x -> parse(Int,x), match(r".(\d+)T(\d+):.", file).captures) for file in google_files]...))

g_data = readtable(google_folder * "/" * google_files[1], separator = '\t')
# e_data = readtable(ecobici_folder * "/" * ecobici_files[1], separator = ',')

e_data = readtable(ecobici_folder * "/" * ecobici_files[1], separator = ',', header = false)

rename!(e_data, [:id_start, :id_end], [:start_id, :end_id])

e_data[:trav_id] = map((x,y) -> (x,y), e_data[:start_id], e_data[:end_id])
g_data[:trav_id] = map((x,y) -> (x,y), g_data[:start_id], g_data[:end_id])

join(g_data, e_data, on = :trav_id, kind = :right)

e_data[ findin(e_data[:trav_id], g_data[:trav_id]), :]

rename!(e_data, [:x1, :x2, :x3, :x4, :x5, :x6, :x7], [])
