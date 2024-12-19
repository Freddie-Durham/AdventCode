include("utils.jl")
using .utils
using GLMakie
using Primes

function is_edge(pos,A1,A2)
    d1 = dist_sq(pos,A1.node)
    d2 = dist_sq(pos,A2.node)
    is_node = (d1==4*d2)||(d2==4*d1)
    return is_node
end

mutable struct Antenna
    freq::UInt32
    node::Vector{Int64}
    edges::Vector{Vector{Int64}}

    function Antenna(f,pos)
        return new(f,pos,Vector{Vector{Int64}}())
    end
end
#=
function add_edges!(A1,A2,width,height)
    #A1 is modified with new edges linking to A2
    vec12 = A2.node-A1.node
    min_vec = utils.factorise_vec(vec12)

    i=0
    forward = A1.node+i*min_vec
    backward = A1.node-i*min_vec
    while utils.inbounds(forward,1,width,1,height)||utils.inbounds(backward,1,width,1,height)
        i+=1
        forward = A1.node+i*min_vec
        backward = A1.node-i*min_vec
        if utils.inbounds(forward,1,width,1,height) && forward != A1.node &&
            forward != A2.node && is_edge(forward,A1,A2)
            push!(A1.edges,forward)
        end
        if utils.inbounds(backward,1,width,1,height) && backward != A1.node &&
            backward != A2.node && is_edge(backward,A1,A2)
            push!(A1.edges,backward)
        end
    end
end
=#
function add_edges!(A1,A2,width,height)
    #A1 is modified with new edges linking to A2
    vec12 = A2.node-A1.node
    min_vec = utils.factorise_vec(vec12)

    i=0
    forward = A1.node+i*min_vec
    backward = A1.node-i*min_vec
    while utils.inbounds(forward,1,width,1,height)||utils.inbounds(backward,1,width,1,height)
        forward = A1.node+i*min_vec
        backward = A1.node-i*min_vec
        if utils.inbounds(forward,1,width,1,height)
            push!(A1.edges,forward)
        end
        if utils.inbounds(backward,1,width,1,height)
            push!(A1.edges,backward)
        end
        i+=1
    end
end

function update_antennas!(antennas,freq,position,width,height)
    #create new antenna with given frequency at given position
    new_A = Antenna(freq,position)
    #loop through antennas, adding edges to old antennas with same frequency
    for i in eachindex(antennas)
        if antennas[i].freq==freq
            add_edges!(antennas[i],new_A,width,height)
        end
    end
    push!(antennas,new_A)
end

function antenna_array(data,width,height)
    antennas = Vector{Antenna}()
    for (j,row) in enumerate(data)
        for (i,val) in enumerate(row)
            if val!='.'
                key = codepoint(val)
                if key<58 && key>47
                    frequency = key-47
                elseif key>64 && key<91
                    frequency = key-54
                elseif key>96 && key<123
                    frequency = key-60
                else
                    println("something went wrong")
                end
                #modify old antenna list and add new antenna
                update_antennas!(antennas,frequency,[i,j],width,height)
            end
        end
    end
    return antennas
end

function dist_sq(pos,signal)
    return (pos[1]-signal[1])^2+(pos[2]-signal[2])^2
end

function node_grid(antennas,width,height)
    grid = zeros(Int64,width,height)
    counter = 0
    for A in antennas
        for e in A.edges
            if grid[e[1],e[2]]==0
                counter+=1
                grid[e[1],e[2]]=1
            end
        end
    end
    return grid,counter
end

function modify!(grid,data)
    for (j,row) in enumerate(data)
        for (i,val) in enumerate(row)
            if val!='.'
                grid[i,j]+=1
            end
        end
    end
end

function main()
    filename = "Day8Data.txt"
    raw_data = readlines(filename)
    width = length(raw_data[1])
    height = length(raw_data)
    
    antennas = antenna_array(raw_data,width,height)
    grid,counter = node_grid(antennas,width,height)
    println("Unique nodes: $counter")
    heatmap(grid)
    #=
    answers = readlines("Day8Target.txt")
    modify!(grid,answers)
    heatmap(grid)
    =#
end
main()


