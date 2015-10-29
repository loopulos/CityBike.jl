#This file contains different functions of network measures
#
##########################################################################
#this is the degree centrality, the argument is the Adjacency matrix
function cent_degree(A::Array{Float64,2})
    n = size(A,1)
    C = Array(Float64, n)
    for i = 1:n
        C[i] = sum(A[i,:]) #the sum over the ith row is the degree centrality of the vertex i
    end
    return C
end
############################################################################
#this is the eigenvector centrality, it takes the adjacency matrix as an argument
function cent_eigenv(A::Array{Float64,2})
    n = size(A,1)
    x = ones(Float64, n)
    λ = eigmax(A) #this is the largest eigenvalue of the adjacency matrix
    C = Array(Float64, n)
    for i = 1:n
        for j = 1:n
            C[i] += 1 / λ * A[i,j] * x[j] #this is the def. of eigenvector centrality according to Bonacich
        end
    end
    return C
end
###########################################################################
