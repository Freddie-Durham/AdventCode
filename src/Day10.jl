include("utils.jl")
using .utils
using GLMakie

function construct_map(data)
    width = length(data[1])
    height = length(data)
    map = zeros(Int64,(width,height))
    trailheads = Vector{Vector{Int64}}()

    for (j,d) in enumerate(data)
        for (i,chr) in enumerate(d)
            map[i,j] = parse(Int64,chr)
            if chr=='0'
                push!(trailheads,[i,j])
            end
        end
    end
    return width,height,map,trailheads
end

function directions()
    return [[1,0],[-1,0],[0,1],[0,-1]]
end

function is_passable(map,location,target,width,height)
    if utils.inbounds(target,1,width,1,height) && 
        map[target[1],target[2]] - map[location[1],location[2]] == 1
        return true
    else
        return false
    end
end

function test_trails!(visited,map,width,height,location)
    if  map[location[1],location[2]] == 9
        visited[location[1],location[2]]+=1
    else
        for dir in directions()
            if is_passable(map,location,location+dir,width,height)
                test_trails!(visited,map,width,height,location+dir)
            end
        end
    end
end

function count_map(map)
    Σ = 0
    for m in map
        Σ +=m
    end
    return Σ
end

function main()
    filename = "Day10Data.txt"
    raw_data = readlines(filename)
    width,height,map,trailheads = construct_map(raw_data)

    Σ = 0
    for head in trailheads
        testmap = zeros(Int64,(width,height))
        test_trails!(testmap,map,width,height,head)
        Σ += count_map(testmap)
    end
    println(length(trailheads))
    println(Σ)
end
main()
