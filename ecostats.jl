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
for i = 1:ns
  for j= 1:ns
     if distro[i,j] > 0
       println(i,"\t",j,"\t ",distro[i,j],"\t",dists[i,j])
     end
   end
end
