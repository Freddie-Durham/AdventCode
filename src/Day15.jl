include("utils.jl")
using .utils
using GLMakie
using LinearAlgebra

function push_rules!(rules,dir)
    for (i,chr) in enumerate(dir)
        if chr=='^'
            push!(rules,1)
        elseif chr=='>'
            push!(rules,2)
        elseif chr=='v'
            push!(rules,3)
        elseif chr=='<'
            push!(rules,4)
        else
            println("Found $chr in rulestring")
        end
    end
end

function walls_boxes_robot(grid_str,width,height)
    walls = utils.vector_of(false,width*height)
    walls = reshape(walls,(width,height))
    Lboxes = copy(walls)
    Rboxes = copy(walls)
    robot = [0,0]

    for (j,g) in enumerate(grid_str)
        for (i,chr) in enumerate(g)
            if chr=='#'
                walls[i,j]=true
            elseif chr=='['
                Lboxes[i,j]=true
            elseif chr==']'
                Rboxes[i,j]=true
            elseif chr=='@'
                robot = [i,j]
            elseif chr!='.'
                println("Found $chr in grid string")
            end
        end
    end
    if robot == [0,0]
        println("Couldn't find robot")
    end
    return walls,Lboxes,Rboxes,robot
end

function get_grid_rules(data)
    is_grid = true
    grid_str = Vector{String}()
    rules = Vector{Int64}()
    for d in data
        if d == ""
            is_grid=false
        elseif is_grid==true
            push!(grid_str,d)
        else
            push_rules!(rules,d)
        end
    end
    return grid_str,rules
end

function GPS(boxX,boxY)
    return boxX-1 + 100*(boxY-1)
end

function get_GPS(Lboxes,Rboxes,width,height)
    Σ = 0
    for i in 1:width
        for j in 1:height
            if Lboxes[i,j]
                if !Rboxes[i+1,j]
                    println("Box error")
                else
                    Σ += GPS(i,j)
                end
            end
        end
    end
    return Σ
end

function direction(move)
    if move==1
        return [0,-1]
    elseif move==2
        return [1,0]
    elseif move==3
        return [0,1]
    elseif move==4
        return [-1,0]
    else
        println("How did we get here? $move")
    end
end

function get_adjacent(pos,walls,Lboxes,Rboxes)
    if walls[pos[1],pos[2]]==true
        return 1
    elseif Lboxes[pos[1],pos[2]]==true
        return 2
    elseif Rboxes[pos[1],pos[2]]==true
        return 3
    else
        return 0
    end
end

function get_horiz_boxes(robot,dir,walls,Lboxes,Rboxes,target)
    moves = 1 #number of horiontal moves
    boxes = 1 #keep track of number of boxes we are moving

    while true
        key = get_adjacent(robot+(moves+1)*dir,walls,Lboxes,Rboxes)
        if key==0
            return boxes
        elseif key==1
            return 0
        elseif key==target
            boxes+=1
        end
        moves+=1
    end
end

function LorR(key)
    if key==2
        return [1,0]
    else
        return [-1,0]
    end
end

function append_LorR!(L_boxes_moved,R_boxes_moved,pos,key)
    if key==2
        if !((pos) in L_boxes_moved)
            push!(L_boxes_moved,pos)
        end
        if !((pos+LorR(key)) in R_boxes_moved)
            push!(R_boxes_moved,pos+LorR(key))
        end
    elseif key==3
        if !((pos) in R_boxes_moved)
            push!(R_boxes_moved,pos)
        end
        if !((pos+LorR(key)) in L_boxes_moved)
            push!(L_boxes_moved,pos+LorR(key))
        end
    end
end

function modify_surface!(surface,old_pos,new_pos,key)
    #if there is a box directly in front, move the front surface to the new box
    old_surface_index = findfirst(==(old_pos),surface)
    surface[old_surface_index] = new_pos
    
    #if a L/R box is the current surface, a corresponding R/L surface must be added
    #however need to check it has not already been added by another box surface
    LorR_surface_index = findfirst(==(new_pos+LorR(key)),surface)
    if isnothing(LorR_surface_index)
        push!(surface,new_pos+LorR(key))
    end
end

function get_vert_boxes(robot,dir,walls,Lboxes,Rboxes,key)
    #list of positions of (L/R) edges of boxes to be moved
    L_boxes_moved = Vector{Vector{Int64}}() 
    R_boxes_moved = Vector{Vector{Int64}}() 
    append_LorR!(L_boxes_moved,R_boxes_moved,robot+dir,key)

    #list of positions corresponding to front faces of boxes
    surface = Vector{Vector{Int64}}()
    push!(surface,robot+dir)
    push!(surface,robot+dir+LorR(key))

    while true
        empty_spaces = 0 #how much of the surface is exposed to empty space
        new_surface = copy(surface)
        for s in surface
            new_s = s+dir
            key = get_adjacent(new_s,walls,Lboxes,Rboxes)

            #println("Surface: $s Hit key: $key")
            if key==1 #hit wall - fail
                return nothing,nothing
            elseif key == 0
                empty_spaces+=1
            else #hit box, need to modify surface
                append_LorR!(L_boxes_moved,R_boxes_moved,new_s,key) #update boxes
                modify_surface!(new_surface,s,new_s,key) 
            end
        end
        #println("spaces: $empty_spaces surface area: $(length(surface))")
        if empty_spaces==length(surface)
            return L_boxes_moved,R_boxes_moved
        end
        surface = new_surface
    end
end

function move_robot!(walls,Lboxes,Rboxes,robot,rules)
    #println("Robot x: $(robot[1]), Robot y: $(robot[2])")
    for move in rules
        dir = direction(move)
        #println("Robot vel x: $(dir[1]), Robot vel y: $(dir[2])")
        key = get_adjacent(robot+dir,walls,Lboxes,Rboxes)
        if key==0
            robot+=dir
        elseif key>1 #box territory
            #println("is horizontal: $(dot([1,0],dir)!=0)")
            if dot([1,0],dir)!=0 # Case 1: moving horizontally
                box_num = get_horiz_boxes(robot,dir,walls,Lboxes,Rboxes,key)
                #println("Box num: $box_num")
                if box_num>0
                    for i in 2:2*box_num
                        p = robot+i*dir
                        Lboxes[p[1],p[2]] = !Lboxes[p[1],p[2]]
                        Rboxes[p[1],p[2]] = !Rboxes[p[1],p[2]]
                    end
                    p = robot+(2*box_num+1)*dir
                    q = robot+dir
                    if key==2
                        Rboxes[p[1],p[2]] = true
                        Lboxes[q[1],q[2]] = false
                    else
                        Lboxes[p[1],p[2]] = true
                        Rboxes[q[1],q[2]] = false
                    end
                    robot+=dir
                end
            else #robot moving vertically
                L_boxes_moved,R_boxes_moved = get_vert_boxes(robot,dir,walls,Lboxes,Rboxes,key)
                if !isnothing(L_boxes_moved) && !isnothing(R_boxes_moved) 
                    for i in eachindex(L_boxes_moved)
                        Lbox = L_boxes_moved[i]
                        Rbox = R_boxes_moved[i]
                        Lboxes[Lbox[1],Lbox[2]]=false
                        Rboxes[Rbox[1],Rbox[2]]=false
                    end
                    for i in eachindex(L_boxes_moved)
                        new_L = L_boxes_moved[i]+dir
                        new_R = R_boxes_moved[i]+dir
                        Lboxes[new_L[1],new_L[2]]=true
                        Rboxes[new_R[1],new_R[2]]=true
                    end
                    robot+=dir
                end
            end
        end
        #println("Robot x: $(robot[1]), Robot y: $(robot[2]), Obstacle type: $key")
    end
    #return heatmap(Lboxes .+ 2*Rboxes .+ 5*walls)
end

function count_boxes(Lboxes,Rboxes)
    ΣL=0
    ΣR=0
    for (L,R) in zip(Lboxes,Rboxes)
        if L
            ΣL+=1
        elseif R
            ΣR+=1
        end
    end
    if ΣL!=ΣR
        println("Boxes don't match")
    end
    return ΣL
end

function modify_map(str)
    new_map = Vector{String}()
    for row in str
        new_row = ""
        for chr in row 
            if chr=='#'
               new_row*="##"
            elseif chr=='O'
                new_row*="[]"
            elseif chr=='@'
                new_row*="@."
            elseif chr=='.'
                new_row*=".."
            end
        end
        push!(new_map,new_row)
    end
    return new_map
end

function main()
    filename = "Day15Data.txt"
    raw_data = readlines(filename)
    grid_str,rules = get_grid_rules(raw_data)
    grid_str = modify_map(grid_str)
    width = length(grid_str[1])
    height = length(grid_str)
    walls,Lboxes,Rboxes,robot = walls_boxes_robot(grid_str,width,height)

    box_start = count_boxes(Lboxes,Rboxes)
    move_robot!(walls,Lboxes,Rboxes,robot,rules)
    box_end = count_boxes(Lboxes,Rboxes)

    println("GPS score: $(get_GPS(Lboxes,Rboxes,width,height)). Box sanity check = $(box_start==box_end)")

    heatmap(Lboxes .+ 2*Rboxes .+ 5*walls)
end
main()