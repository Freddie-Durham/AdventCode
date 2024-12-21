include("utils.jl")
using .utils
using GLMakie

mutable struct Node
    ID::Int64 #represents position and direction
    ForwardPath::Dict{Int64,Int64} #connected nodes and cost of connection
    Cost::Int64 #cost from origin
    Prev::Int64

    function Node(ID,edge_dict)
        new(ID,edge_dict,typemax(Int64),-1)
    end
end

function turn_cost()
    return 1000
end

function direction_ID(dir)
    if dir == [1,0]
        return 0
    elseif dir == [-1,0]
        return 1
    elseif dir == [0,1]
        return 2
    elseif dir == [0,-1]
        return 3
    end
end

function encode(pos,dir,width,height)
    dir_ID = direction_ID(dir)
    return (pos[1]-1) + (pos[2]-1)*width + dir_ID*width*height
end

function create_node!(pos,maze,grid_str,width,height)
    #make 4 nodes, one for each possible direction
    #get edges for each node, ie. step forward if no wall (cost=1),
    #turn right or left (cost=1000)
    for d in utils.directions()
        ID = encode(pos,d,width,height)
        edge_dict = Dict{Int64,Int64}()

        rID = encode(pos,utils.turn_right(d),width,height)
        lID = encode(pos,-utils.turn_right(d),width,height)
        edge_dict[rID] = turn_cost()
        edge_dict[lID] = turn_cost()

        fwd = pos + d
        if grid_str[fwd[1]][fwd[2]]!='#'
            fID = encode(fwd,d,width,height)
            edge_dict[fID] = 1
        end
        new_node = Node(ID,edge_dict)
        push!(maze,new_node)
    end
end

function get_node(nodelist,ID)
    #returns position of node in nodelist
    for (i,node) in nodelist
        if node.ID == ID 
            return i
        end
    return nothing
end

function maze_start_location(grid_str,width,height)
    maze = Vector{Node}()

    reindeer = [0,0]
    goal = [0,0]

    for (j,g) in enumerate(grid_str)
        for (i,chr) in enumerate(g)
            if chr!='#'
                create_node!([i,j],maze,grid_str,width,height)
                if chr=='S'
                    startID = encode([i,j],[-1,0],width,height)
                    maze[get_node(maze,startID)].Cost = 0
                elseif chr=='E'
                    goalIDs = Vector{Int64}
                    for d in utils.directions()
                        push!(goalIDs,encode([i,j],d,width,height))
                    end
                end
            end
        end
    end
    if reindeer == [0,0]
        println("Couldn't find reindeer")
    elseif goal == [0,0]
        println("Couldn't find goal")
    end
    return maze,startID,goalIDs
end

function ID_in(ID,nodes)
    for n in nodes 
        if n.ID == ID
            return true
        end
    end
    return false
end

function djikstra_solve(maze,startID,goalIDs)
    unsearched_nodes = deepcopy(maze)
    for node in maze 
        if ID_in(node.ID,unsearched_nodes)
            #remove node from unsearched
            filter!(e->e!=node,unsearched_nodes)

            for (nextID,cost) in node.ForwardPath
                if ID_in(nextID,unsearched_nodes)

                end
            end
        end
    end

end

function main()
    filename = "Day16Test.txt"
    #ans = 7036,45
    #filename = "Day16Test2.txt"
    #ans = 11408,64
    #filename = "Day16Data.txt"
    #ans = 109496,?

    raw_data = readlines(filename)
    width = length(raw_data[1])
    height = length(raw_data)
    maze,startID,goalIDs = maze_start_location(raw_data,width,height) 

    djikstra_solve(maze,startID,goalIDs)

    #println("Search complete: best score was $best_score")

    #println("Number of seats: $(length(path_nodes))")

end

main()