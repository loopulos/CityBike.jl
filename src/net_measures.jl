#This file contains functions of different network measures
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
    C = zeros(Float64, n)
    for i = 1:n
        for j = 1:n
            C[i] += 1 / λ * A[i,j] * x[j] #this is the def. of eigenvector centrality according to Bonacich
        end
    end
    return C
end
###########################################################################
#the next function calculates the closeness centrality
function cent_closeness(A::Array{Float64,2})
    n = size(A,1)
    cc = zeros(Float64, n) #empty array for the closeness centrality
    for i = 1:n
        for j = 1:n
            lt = 0
            for r = 1:n-1 #this cycle calculates the closest path between vertices
                B = A^r
                if B[i,j] > 0
                    d = r   #d is the shortest distance
                    break
                end
            end
            lt += 1/(n - 1) * d
        end
        cc[i] = 1 / lt #this is the closeness centrality of the vertex i
    end
    return cc
end
