# using PyPlot

path = "/Users/mzumaya/Google Drive/EcobiciDATA/EcobiciDF/"
# path = "/home/alfredo/GoogleDrive/EcobiciDATA/EcobiciDF/"

files = filter(x -> ismatch( r"filt_\d+.", x), readdir(path))

# dist_pairs = zeros(Int64, length(files))

for j in 1:length(files)

  data = readcsv(path*files[j])

  println(files[j])

  pairs = Dict();

  for i in 2:size(data,1)

    key = (data[i, 1], data[i, 2])

    if key[1] != key[2] && key[1] < 1000 && key[2] < 1000

      if haskey(pairs, key) == false

        pairs[key] = 1

      else

        pairs[key] += 1

      end

    end

  end

  # ordena llaves por estacion de salida
  keys_sort = sort(collect(keys(pairs)))

  file = open(path*"uso_"*split(files[j], "filt_")[2], "w")

  println(file, "id_start,id_end,freq")

  for key in keys_sort
    println(file, key[1], ",", key[2], ",", pairs[key])
  end

  close(file)

  #writecsv("$(files[j])", pairs)
  # println(length(values(pairs)))

  # pairs_freq = zeros()

  # dist_pairs[j] = length(keys(pairs))

end

# plot([i for i in 1:length(dist_pairs)], dist_pairs)
