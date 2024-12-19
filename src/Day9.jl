include("utils.jl")
using .utils

function parse_data(data)
    is_occupied = Vector{Int64}()
    compacted_data = Vector{Vector{Int64}}()

    is_data = 0
    filenum = 0
    for d in data
        val = parse(Int64,d)
        if is_data%2==0
            push!(compacted_data,[val,filenum])
            filenum+=1        
        else
            push!(is_occupied,val)
        end
        is_data+=1
    end
    return is_occupied,compacted_data
end

function fill_empty!(sorted,unsorted,unoccupied,occ_iter)
    num_empty = unoccupied[occ_iter]
    old_empty = -1
    #search for file that fits into unoccupied space
    while old_empty != num_empty
        old_empty=num_empty
        for i in length(unsorted):-1:1
            fill_len = unsorted[i][1]
            if fill_len<=num_empty && unsorted[i][2]>-1 && fill_len!=0
                for _ in 1:fill_len
                    push!(sorted,unsorted[i][2])
                end
                unsorted[i][2] = -1
                num_empty-=fill_len
            end
        end
    end
    for _ in 1:num_empty
        push!(sorted,-1)
    end
end

function sort_data(unoccupied,unsorted)
    sorted = Vector{Float64}()

    is_occ = 0
    occ_iter = 1
    data_iter = 1
    while occ_iter<length(unoccupied)+1||data_iter<length(unsorted)+1
        if is_occ%2==0
            filenum = unsorted[data_iter][2]
            filelen = unsorted[data_iter][1]
            for _ in 1:filelen
                push!(sorted,filenum)
            end
            unsorted[data_iter][2] = -1
            data_iter+=1
        else
            fill_empty!(sorted,unsorted,unoccupied,occ_iter)
            occ_iter+=1
        end
        is_occ+=1
    end
    return sorted
end

function main()
    filename = "Day9Data.txt"
    raw_data = readlines(filename)
    
    is_occupied,unsorted_data = parse_data(raw_data[1])
    
    sorted = sort_data(is_occupied,unsorted_data)

    checksum = 0
    for (i,s) in enumerate(sorted)
        if s!=-1
            checksum+=(i-1)*s
        end
    end
    println("Checksum = $checksum")
    
end
main()

#0,-1,-1,-1,-1,-1,1,2,3,4
#0,4,3,2,1,-1,-1,-1,-1,-1