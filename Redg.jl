using LightGraphs
using DataFrames
admat = readdlm("/home/alfredo/Git/EcobiciDF/dists.tsv")
#g = Graph(275)
#edge_dists = zeros(275,275)
for u = 1:100
  g = Graph(275)
  edge_dists = zeros(275,275)
  for i = 1:275
    for j = 1:275
      if admat[i,j] == 0
        continue
      end
      if admat[i,j] < u/10
        continue
      end
    #println("si")
      edge_dists[i,j] = admat[i,j]
      if has_edge(g, i, j) == true
        continue
      end
      add_edge!(g, i, j)
    end
  end
  println(u/10,"  ", density(g))
  #println(degree_centrality(g, normalize=true))
end
