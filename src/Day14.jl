include("utils.jl")
using .utils
using GLMakie

mutable struct Robot
    pos::Vector{Int64}
    vel::Vector{Int64}

    function Robot(str)
        (Pstr,Vstr) = split(str)
        return new(get_vec(Pstr),get_vec(Vstr))
    end
end

function get_vec(str)
    peq = findfirst('=',str)
    pcom = findfirst(',',str)
    Xstr = ""
    Ystr = ""
    for i in peq+1:length(str)
        if i<pcom
            Xstr*=str[i]
        elseif i>pcom
            Ystr*=str[i]
        end
    end
    return [parse(Int64,Xstr),parse(Int64,Ystr)]
end

function bounds(str)
    if str == "Day14Test.txt"
        return 11,7
    elseif str == "Day14Data.txt"
        return 101,103
    else
        println("wrong string")
        return nothing
    end
end

function populate_grid(robots,width,height)
    grid = zeros(Int64,(width,height))
    for robot in robots
        grid[robot.pos[1]+1,robot.pos[2]+1] += 1
    end
    return grid
end

function step!(robots,width,height)
    buffer=5
    for r in robots
        r.pos[1] = (buffer*width+(r.pos[1]+r.vel[1]))%width
        r.pos[2] = (buffer*height+(r.pos[2]+r.vel[2]))%height
    end
end

function count_regions(grid,width,height)
    xcutoff = Int64(floor(width/2))+1
    ycutoff = Int64(floor(height/2))+1
    #println("x cut: $xcutoff, y cut: $ycutoff")
    NW = 0
    NE = 0
    SW = 0
    SE = 0
    for i in 1:width
        for j in 1:height
            if j<ycutoff #South half
                if i<xcutoff #West quadrant
                    SW+=grid[i,j]
                elseif i>xcutoff #East quadrant
                    SE+=grid[i,j]
                end
            elseif j>ycutoff #North half
                if i<xcutoff #West quadrant
                    NW+=grid[i,j]
                elseif i>xcutoff  #East quadrant
                    NE+=grid[i,j]
                end
            end
        end
    end
    return max(max(max(NW,NE),SW),SE)
end

function get_stats(filename)
    raw_data = readlines(filename)
    width,height = bounds(filename)
    robots = Vector{Robot}()
    for raw in raw_data
        push!(robots,Robot(raw))
    end
    density_vec = Vector{Float64}()
    for _ in 1:1000
        step!(robots,width,height)
        grid = populate_grid(robots,width,height)
        push!(density_vec,count_regions(grid,width,height))
    end
    return utils.mean_dev(density_vec)
end

function main()
    filename = "Day14Data.txt"
    mean, std_dev = get_stats(filename)

    raw_data = readlines(filename)
    width,height = bounds(filename)
    robots = Vector{Robot}()
    for raw in raw_data
        push!(robots,Robot(raw))
    end
    grid = populate_grid(robots,width,height)
    
    dnsty = mean
    significance = 7
    seconds = 0
    while abs(dnsty-mean)<(significance*std_dev)
        step!(robots,width,height)
        seconds+=1
        grid = populate_grid(robots,width,height)
        dnsty = count_regions(grid,width,height)
    end
    println(seconds)
    heatmap(grid)
end
main()
