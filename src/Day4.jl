include("utils.jl")
using .utils

function get_wordsearch()
    rows = readlines("Day4Data.txt")
    xdims = length(rows[1])
    ydims = length(rows)

    grid = Vector{Char}([])
    for r in rows
        for c in r
            push!(grid,c)
        end
    end
    return reshape(grid,(xdims,ydims)),xdims,ydims
end

function main()
    grid,xdims,ydims = get_wordsearch()
    count = 0
    for i in 1:xdims
        for j in 1:ydims
            if grid[i,j]=='X'
                directions = utils.nearest_neighbours(xdims,ydims,i,j,3)
                for d in directions
                    if grid[i+d[1],j+d[2]]=='M'&& grid[i+2*d[1],j+2*d[2]]=='A'&& grid[i+3*d[1],j+3*d[2]]=='S'
                        count+=1
                    end
                end
            end
        end
    end
    println(count)
end

function part2()
    grid,xdims,ydims = get_wordsearch()
    MAS = 0
    for i in 1:xdims
        for j in 1:ydims
            if grid[i,j]=='A'
                directions = utils.nearest_diags(xdims,ydims,i,j,1)
                if length(directions)==4
                    d1 = string(grid[i+1,j+1],grid[i-1,j-1])
                    d2 = string(grid[i-1,j+1],grid[i+1,j-1])
                    if count(==('S'), d1)==1 && count(==('M'), d1)==1 &&
                       count(==('S'), d2)==1 && count(==('M'), d2)==1
                       MAS+=1
                    end
                end
            end
        end
    end
    println(MAS)
end

#main()
part2()

