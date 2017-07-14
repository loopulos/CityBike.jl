using Base.Dates
function parsedate(ds)
    clean = strip(replace(ds, r"(AM|PM)", ""))
    date  = DateTime(clean, DateFormat("HH:MM:SS"))
    if contains(ds, "PM") && hour(date) != 12
        date += Hour(12)
    elseif contains(ds, "AM") && hour(date) == 12
        date -= Hour(12)
    end
    return date
end

file = readcsv("/media/alfredo/Killer-Rabbit1.5/Ecobicis/CDMX/2016-08n.csv")
file[1,6]
d = parsedate(file[1,6])
