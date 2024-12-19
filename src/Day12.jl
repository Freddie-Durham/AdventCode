include("utils.jl")
using .utils
using GLMakie

struct Node
    edges::Vector{Vector{Int64}}
    position::Vector{Int64}

    function Node(dir_to_node,pos)
        #modify nodes so that edges point away from other nodes
        dir_from_node = Vector{Vector{Int64}}()
        for d in utils.directions()
            if !(d in dir_to_node)
                push!(dir_from_node,d)
            end
        end
        return new(dir_from_node,pos)
    end
end

struct Graph
    nodes::Vector{Node}
end

struct Edge 
    direction::Vector{Int64}
    node_pos::Vector{Int64}
end

function get_garden(data,width,height)
    vegetables = Dict{Char, Int64}()
    veg_count = 0
    garden = zeros(Int64,(width,height))
    for (j,d) in enumerate(data)
        for (i,chr) in enumerate(d)
            veg_id = get(vegetables,chr,nothing)
            if isnothing(veg_id)
                vegetables[chr]=veg_count
                garden[i,j] = veg_count
                veg_count+=1
            else
                garden[i,j] = veg_id
            end
        end
    end
    return garden,vegetables
end

function check_directions(garden,pos,width,height)
    valid_dirs = Vector{Vector{Int64}}()
    target_val = garden[pos[1],pos[2]]
    for dir in utils.directions()
        adj = pos+dir
        if utils.inbounds(adj,1,width,1,height) &&
            garden[adj[1],adj[2]]==target_val
            push!(valid_dirs,dir)
        end
    end
    return valid_dirs
end

function graph_walk!(garden,width,height,node_pos,nodes_visited,node_edges)
    valid_directions = check_directions(garden,node_pos,width,height)
    
    if !(node_pos in nodes_visited)
        #record that we visited this node 
        push!(nodes_visited,node_pos)
        #record number of edges node has
        push!(node_edges,valid_directions)
    end

    #check if we have reached the end of our node searching
    #ie no more unchecked nodes in group
    not_visited = Vector{Vector{Int64}}()
    for valid_d in valid_directions
        if !(node_pos+valid_d in nodes_visited)
            push!(not_visited,node_pos+valid_d)
        end
    end
    #if we do have unvisited nodes, visit them recursively
    for location in not_visited
        graph_walk!(garden,width,height,location,nodes_visited,node_edges)
    end
end

function construct_graphs(garden,width,height)
    graphs = Vector{Graph}()
    visited = Vector{Vector{Int64}}()

    for i in 1:width
        for j in 1:height
            current_pos = [i,j]
            if !(current_pos in visited)
                nodes_visited = Vector{Vector{Int64}}()
                node_edges = Vector{Vector{Vector{Int64}}}()
                graph_walk!(garden,width,height,current_pos,nodes_visited,node_edges)
                node_list = Vector{Node}()
                for (node_pos,edges) in zip(nodes_visited,node_edges)
                    new_node = Node(edges,node_pos)
                    push!(node_list,new_node)
                    push!(visited,node_pos)
                end
                push!(graphs,Graph(node_list))
            end
        end
    end
    return graphs
end

function unique_garden(graphs,width,height)
    garden = zeros(Int64,(width,height))
    for (i,graph) in enumerate(graphs)
        for node in graph.nodes
            pos = node.position
            garden[pos[1],pos[2]] = i
        end
    end
    return garden
end

function turn_right(dir)
    #negative of turn_right is turn_left
    if dir==[1,0]
        return [0,1]
    elseif dir==[0,1]
        return [-1,0]
    elseif dir==[-1,0]
        return [0,-1]
    elseif dir==[0,-1]
        return [1,0]
    else
        println("Invalid direction: $dir")
    end
end

function is_in(current_pos,nodes)
    for (i,node) in enumerate(nodes) 
        if node.position==current_pos
            return i 
        end
    end
    return nothing
end

function match_edge(current_edge,edges_visited)
    for edge in edges_visited
        if edge.direction == current_edge.direction && edge.node_pos == current_edge.node_pos
            return true
        end
    end
    return false
end 

function perimeter_walk!(edges_visited,current_edge,nodes)
    #number of sides = number of right angles turned through
    turns_made = 0
    #pick rightwards to start walking
    walk_dir = turn_right(current_edge.direction)

    while match_edge(current_edge,edges_visited)==false
        push!(edges_visited,current_edge)
        try_walk = is_in(current_edge.node_pos+walk_dir,nodes)
        if !(isnothing(try_walk))
            #try_walk is now an index pointing to a node in nodes
            if current_edge.direction in nodes[try_walk].edges
                #easy case: can continue walk in same direction
                current_edge = Edge(current_edge.direction,nodes[try_walk].position)
            else
                #update current edge by turning left 
                #and moving in move direction + edge direction
                current_edge = Edge(-turn_right(current_edge.direction),current_edge.node_pos+current_edge.direction+walk_dir)
                #turn left
                walk_dir = -turn_right(walk_dir)
                turns_made+=1
            end
        else
            #need to turn right
            walk_dir = turn_right(walk_dir)
            #update edge ny turning right but dont change node pos
            current_edge = Edge(turn_right(current_edge.direction),current_edge.node_pos)
            turns_made+=1
        end
    end
    return turns_made
end

function perimeter(graph)
    num_sides = 0
    edges_visited = Vector{Edge}()
    for node in graph.nodes
        for edg in node.edges
            unique_edge = Edge(edg,node.position)
            if !(unique_edge in edges_visited)
                #we have found a new perimeter to explore
                #we will return the number of sides of the perimeter
                #also modifies edges_visited so they are not explored twice
                num_sides += perimeter_walk!(edges_visited,unique_edge,graph.nodes)
            end
        end
    end
    return num_sides
end

function price(graph)
    perim = perimeter(graph)
    area = length(graph.nodes)
    return perim*area
end

function old_price(graph)
    perim = 0
    area = 0
    for node in graph.nodes
        perim+=length(node.edges)
        area+=1
    end
    return perim*area
end

function get_price(graphs)
    total_price = 0
    for graph in graphs
        total_price += price(graph) 
    end
    return total_price
end

function main()
    filename = "Day12Data.txt"
    raw_data = readlines(filename)
    width = length(raw_data[1])
    height = length(raw_data)
    garden,veg_dict = get_garden(raw_data,width,height)
    
    veg_graphs = construct_graphs(garden,width,height)
    println(get_price(veg_graphs))

    #=
    unique = unique_garden(veg_graphs,width,height)
    heatmap(unique)
    =#
    
end
main()