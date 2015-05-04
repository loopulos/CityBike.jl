using DataFrames
distancia = readtable("/home/alfredo/Ecobici/ecobici_distancias.csv", header=false)
ns = 275
distancia[1,2]
dists = zeros(ns,ns)
for i = 1:35778
  dists[distancia[i,1],distancia[i,2]] = dists[distancia[i,2],distancia[i,1]] = distancia[i,3]
end
#v2010 = readtable("/home/alfredo/Ecobici/2010.csv", header=false)
#v2011 = readtable("/home/alfredo/Ecobici/2011.csv", header=false)
#v2012 = readtable("/home/alfredo/Ecobici/2012.csv", header=false)
#v2013 = readtable("/home/alfredo/Ecobici/2013.csv", header=false)
#startend = readtable("/home/alfredo/Ecobici/ecobici_trayectos.tsv", header=false)
ini = readdlm("/home/alfredo/Ecobici/init.txt", Int)
fin = readdlm("/home/alfredo/Ecobici/final.txt", Int)
distro = zeros(ns,ns)
N = 0
for i= 1:length(ini)
  if ini[i] <= ns && fin[i] <= ns
    N += 1
    distro[ini[i],fin[i]] += 1
  end
end
admat = zeros(ns,ns)
println(distro[34,30])
writetable("./matriz.tsv", convert(DataFrame, distro), header=false)
writetable("dists.tsv", convert(DataFrame, dists), header=false)

for i = 1:ns
  for j= 1:ns
     if distro[i,j] > 0
        admat[i,j] = 1/N #es con la normalizacion nada mas
       #println(i,"\t",j,"\t ",distro[i,j],"\t",dists[i,j])
      else
       admat[i,j] = 0
    end
   end
end
writetable("adjmat.tsv", convert(DataFrame, admat), header=false)
