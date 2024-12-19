include("utils.jl")
using .utils
using GLMakie

#try implementing with Djikstra's
#nvm for some reason starting direction east corresponded to [-1,0]

function maze_start_location(grid_str,width,height)
    maze_up = utils.vector_of(110000,width*height)
    maze_up = reshape(maze_up,(width,height))
    walls = utils.vector_of(false,width*height)
    walls = reshape(walls,(width,height))

    reindeer = [0,0]
    goal = [0,0]

    for (j,g) in enumerate(grid_str)
        for (i,chr) in enumerate(g)
            if chr=='#'
                maze_up[i,j] = -1
                walls[i,j] = true
            elseif chr=='S'
                reindeer = [i,j]
                maze_up[i,j] = 0
            elseif chr=='E'
                goal = [i,j]
            elseif chr!='.'
                println("Found $chr in grid string")
            end
        end
    end
    if reindeer == [0,0]
        println("Couldn't find reindeer")
    elseif goal == [0,0]
        println("Couldn't find goal")
    end

    maze_scores = utils.vector_of(maze_up,4)
    maze_down = deepcopy(maze_up)
    maze_scores[2] = maze_down
    maze_left = deepcopy(maze_up)
    maze_scores[3] = maze_left
    maze_right = deepcopy(maze_up)
    maze_scores[4] = maze_right

    return maze_scores,walls,reindeer,goal 
end

function direction_ID(dir)
    if dir == [1,0]
        return 1
    elseif dir == [-1,0]
        return 2
    elseif dir == [0,1]
        return 3
    elseif dir == [0,-1]
        return 4
    end
end

function turn_cost()
    return 1000
end

function explore_maze!(maze_scores,current_pos,current_dir,current_score,goal)
    ID = direction_ID(current_dir)
    if current_score <= maze_scores[ID][current_pos[1],current_pos[2]]
        maze_scores[ID][current_pos[1],current_pos[2]] = current_score
        if current_pos != goal
            #straight on
            next_pos = current_pos+current_dir
            explore_maze!(maze_scores,next_pos,current_dir,current_score+1,goal)
               
            #turn right
            next_dir = utils.turn_right(current_dir)
            next_pos = current_pos+next_dir
            explore_maze!(maze_scores,next_pos,next_dir,current_score+1+turn_cost(),goal)

            #turn left
            next_dir = -utils.turn_right(current_dir)
            next_pos = current_pos+next_dir
            explore_maze!(maze_scores,next_pos,next_dir,current_score+1+turn_cost(),goal)
        end
    end
end

function maze_score(maze,g)
    m1 = maze[1][g[1],g[2]]
    m2 = maze[2][g[1],g[2]]
    m3 = maze[3][g[1],g[2]]
    m4 = maze[4][g[1],g[2]]
    return min(min(min(m1,m2),m3),m4)
end

function get_min_maze(maze,width,height)
    min_maze = deepcopy(maze[1])
    for i in 1:width
        for j in 1:height
            min_maze[i,j] = maze_score(maze,[i,j])
        end
    end
    return min_maze
end

function get_seats(nodes,width,height)
    maze_map = zeros(Int64,(width,height))
    for n in nodes
        maze_map[n[1],n[2]]=1
    end
    return maze_map
end

function min_dir(maze,p)
    s1 = maze[1][p[1],p[2]]
    s2 = maze[2][p[1],p[2]]
    s3 = maze[3][p[1],p[2]]
    s4 = maze[4][p[1],p[2]]
    smin = min(min(min(s1,s2),s3),s4)

    #println("1 $s1 2 $s2 3 $s3 4 $s4")

    d = utils.directions()
    if s1 == smin
        return d[1]
    elseif s2 == smin
        return d[2]
    elseif s3 == smin
        return d[3]
    elseif s4 == smin
        return d[4]
    end
end

function nodes_on_best_path!(path_nodes,maze,current_pos,current_dir,start_pos)
    if !(utils.is_in(current_pos,path_nodes)) 
        push!(path_nodes,current_pos)
    end
    if current_pos != start_pos
        current_score = maze_score(maze,current_pos)

        next_pos = current_pos+current_dir
        forward_score = maze_score(maze,next_pos)
        if forward_score == -1
            forward_score = Inf
        end

        next_dir = utils.turn_right(current_dir)
        next_pos = current_pos+next_dir
        right_score = maze_score(maze,next_pos)
        if right_score == -1
            right_score = Inf
        else 
            right_score -= turn_cost()
        end

        next_dir = -utils.turn_right(current_dir)
        next_pos = current_pos+next_dir
        left_score = maze_score(maze,next_pos)
        if left_score == -1 
            left_score = Inf
        else
           left_score -= turn_cost()
        end

        if current_pos == [16,2]
            println("Location: $current_pos. Forward score: $forward_score. Right score: $right_score Left score: $left_score")
        end

        best_next_score = min(min(min(forward_score,left_score),right_score),current_score)

        if forward_score==best_next_score
            next_pos = current_pos+current_dir
            nodes_on_best_path!(path_nodes,maze,next_pos,-min_dir(maze,next_pos),start_pos)
        end

        if right_score==best_next_score
            next_pos = current_pos+utils.turn_right(current_dir)
            nodes_on_best_path!(path_nodes,maze,next_pos,-min_dir(maze,next_pos),start_pos)
        end

        if left_score==best_next_score
            next_pos = current_pos-utils.turn_right(current_dir)
            nodes_on_best_path!(path_nodes,maze,next_pos,-min_dir(maze,next_pos),start_pos)
        end
    end
end

function main()
    #filename = "Day16Test.txt"
    #ans = 7036,45
    filename = "Day16Test2.txt"
    #ans = 11408,64
    #filename = "Day16Data.txt"
    #ans = 109496,?

    raw_data = readlines(filename)
    width = length(raw_data[1])
    height = length(raw_data)
    maze,walls,reindeer,goal = maze_start_location(raw_data,width,height) 

    println("Width = $width. Height = $height")

    explore_maze!(maze,reindeer,[-1,0],0,goal)
    best_score = maze_score(maze,goal)
    println("Search complete: best score was $best_score")

    path_nodes = Vector{Vector{Int64}}()
    nodes_on_best_path!(path_nodes,maze,goal,[0,1],reindeer)
    println("Number of seats: $(length(path_nodes))")

    maze_map = get_seats(path_nodes,width,height)
    heatmap(maze_map  + 5*walls)
end

main()