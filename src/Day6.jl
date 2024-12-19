include("utils.jl")
using .utils
using GLMakie

function count_grid(grid)
    Σ = 0
    for g in grid
        Σ+=g
    end
    return Σ
end

function get_visit_pos(position,direction,width,height)
    if direction==[0,1]
        d = 0
    elseif direction==[0,-1]
        d = 1
    elseif direction==[1,0]
        d = 2
    elseif direction==[-1,0]
        d = 3
    else
        print("how did we get here?")     
    end
    return position[1]+position[2]*width+d*width*height
end

function guard_walk!(guard_key,position,width,height)
    #list of 4-vecs containing position and direction
    visited_list = zeros(width*height*4)
    direction = [0,-1]
    turn_right = [0 -1;
                  1 0]
    id = get_visit_pos(position,direction,width,height)
    visited_list[id] = 1

    while utils.inbounds(position+direction,1,width,1,height) 
        while utils.inbounds(position+direction,1,width,1,height) && 
              guard_key[(position+direction)[1],(position+direction)[2]]==1.0
            direction = turn_right*direction
        end
        if guard_key[(position+direction)[1],(position+direction)[2]]==0.0
            position += direction
            id = get_visit_pos(position,direction,width,height)
            if visited_list[id] == 0
                visited_list[id] = 1 
            else
                return true
            end
        end
    end
    return false
end

function get_key!(grid,key) #modifies key and returns starting position
    start_pos = nothing
    for (j,row) in enumerate(grid)
        for (i,chr) in enumerate(row)
            if chr =='.'
                key[i,j] = 0.0
            elseif chr == '#'
                key[i,j] = 1.0
            elseif chr == '^'
                key[i,j] = 0.0
                start_pos = [i,j]
            end
        end
    end
    return start_pos
end

function try_obstacles(guard_key,start_pos,width,height)
    stuck_count = 0
    for i in 1:width
        for j in 1:height
            if start_pos==[i,j]
                println("hit start pos")
            end
            if guard_key[i,j]==0.0 && start_pos!=[i,j]
                new_key = copy(guard_key)
                new_key[i,j] = 1.0
                if_stuck = guard_walk!(new_key,start_pos,width,height)
                if if_stuck
                    stuck_count+=1
                end
            end
        end
        println("$(100*i/width)% done. $stuck_count obstacles found so far")
    end
    return stuck_count
end

function main()
    guard_grid = readlines("Day6Data.txt")
    wid = length(guard_grid[1])
    hei = length(guard_grid)
    guard_key = reshape(zeros(wid*hei),(wid,hei))
    start_pos = get_key!(guard_grid,guard_key)
    if start_pos === nothing
        println("Start pos not found")
    else
        num_obstacles = try_obstacles(guard_key,start_pos,wid,hei)
        println("Done. Found $num_obstacles obstacles")
    end
end
main()