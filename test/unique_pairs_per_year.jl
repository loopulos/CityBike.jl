using PyPlot

path = "/Users/mzumaya/Google Drive/EcobiciDATA/EcobiciDF/"

files = filter(x -> ismatch( r"filt_\d+.csv", x), readdir(path))

dist_pairs = zeros(Int64, length(files))

for j in 1:length(files)

  data = readcsv(path*files[j])

  println(files[j])

  pairs = Dict()

  for i in 2:size(data,1)

    key = (data[i, 1], data[i, 2])

    if haskey(pairs, key) == false

      pairs[key] = 1

    else

      pairs[key] += 1

    end

  end

  println(length(values(pairs)))

  # pairs_freq = zeros()

  dist_pairs[j] = length(keys(pairs))

end

plot([i for i in 1:length(dist_pairs)], dist_pairs)
