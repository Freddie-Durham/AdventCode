module utils

export *

using Statistics
using Primes

function StrtoFloat(ls,typeinfo::T) where T<:Any
    nums = Vector{T}([])
    for s in ls 
        push!(nums,parse(T,s))
    end
    return nums
end

function two_lists(ls::Vector{T}) where T<:Any
    a = Vector{T}([])
    b = Vector{T}([])

    for (i,s) in enumerate(ls)
        if i%2==0
            push!(a,s)
        else
            push!(b,s)
        end
    end
    return a,b
end

function get_diff(list1,list2)
    total = 0.0
    for (a,b) in zip(list1,list2)
        total += abs(a-b)
    end
    return total
end

function count_similar(num,ls)
    count = 0
    for s in ls
        if num==s
            count+=1
        end
    end
    return count
end

function count_conditions(condition,ls)
    count=0
    for s in ls
        if condition(s)
            count+=1
        end
    end
    return count
end

function inbounds(val,minx,maxx,miny,maxy)
    if val[1] >= minx && val[1] <= maxx && val[2] >= miny && val[2] <= maxy
        return true
    else
        return false
    end
end

function nearest_neighbours(xdims,ydims,i,j,dist)
    neighbours = Vector{Vector{Int64}}([])
    for diffy in -1:1:1
        for diffx in -1:1:1
            if !(diffx==0 && diffy==0)
                vec = [diffx,diffy]
                if inbounds([i,j].+dist*vec,1,xdims,1,ydims)
                    push!(neighbours,vec)
                end
            end
        end
    end
    return neighbours
end

function nearest_diags(xdims,ydims,i,j,dist)
    diags = Vector{Vector{Int64}}([])
    for diffy in -1:1:1
        for diffx in -1:1:1
            if !(diffx==0 || diffy==0)
                vec = [diffx,diffy]
                if inbounds([i,j].+dist*vec,1,xdims,1,ydims)
                    push!(diags,vec)
                end
            end
        end
    end
    return diags
end

function get_data(filename,spl,typeinfo::T) where T<:Any
    rows = readlines(filename)
    data = Vector{Vector{T}}([])
    for r in rows
        push!(data,StrtoFloat(split(r,spl),typeinfo))
    end
    return data
end

function vector_of(val::T,length) where T<: Any
    v = Vector{T}([])
    for i in 1:length
        push!(v,val)
    end
    return v
end

function get_median(vec)
    sorted_vec = sort(vec)
    middle_index = convert(Int64,1+round((length(vec)-1)/2))
    return sorted_vec[middle_index]
end

function swap!(ind1,ind2,vec)
    val1 = vec[ind1]
    val2 = vec[ind2]
    vec[ind1]=val2
    vec[ind2]=val1
end

function swap_array!(pos1,pos2,arr)
    val1 = arr[pos1[1],pos1[2]]
    val2 = arr[pos2[1],pos2[2]]
    arr[pos1[1],pos1[2]]=val2
    arr[pos2[1],pos2[2]]=val1
end

function convertGL(grid,width,height)
    for i in 1:width
        for j in 1:convert(Int64,floor(height/2))
            swap_array!([i,j],[i,height-j],grid)
        end
    end
    return grid
end

function shift_index!(start_ind,end_ind,vec)#shifts entry from start index to end index
    dir = sign(end_ind-start_ind)
    for i in start_ind:dir:end_ind-dir
        swap!(i,i+dir,vec)
    end
end

function is_in(val,vec)
    for v in vec
        if v==val
            return true
        end
    end
    return false
end

function approx(num1,num2,tol)
    if abs(num1-num2)>tol
        return false
    else
        return true
    end
end

function data_to_hm(data) #assume 2D data
    hm_data = copy(data)
    for i in 1:length(data[1])
        for j in 1:length(data[2])
            hm_data[1+length(data[1])-i,1+length(data[2])-j] = data[i,j]
        end
    end
    return hm_data
end

function mean_dev(data)
    mn = mean(data)
    return mn,std(data,mean=mn)
end

function factorise_vec(vec::Vector{Int64})
    #takes a vector of int 64 and calculates the prime factors
    #uses these factors to find the minimum integer vec of same direction
    
    x_factors = collect(factor(vec[1]))
    y_factors = collect(factor(vec[2]))

    x_iter = 1
    y_iter = 1

    new_vec = [1,1]

    while x_iter<length(x_factors)+1 || y_iter<length(y_factors)+1
        if x_iter>length(x_factors)
            new_vec[2]*=first.(y_factors[y_iter])^last.(y_factors[y_iter])
            y_iter+=1
        elseif y_iter>length(y_factors)
            new_vec[1]*=first.(x_factors[x_iter])^last.(x_factors[x_iter])
            x_iter+=1
        elseif first.(x_factors[x_iter])==first.(y_factors[y_iter])
            remainder = last.(x_factors[x_iter]) - last.(y_factors[y_iter])
            xrem = max(0,remainder)
            yrem = max(0,-remainder)
            new_vec[1]*=max(1,xrem*first.(x_factors[x_iter]))
            new_vec[2]*=max(1,yrem*first.(y_factors[y_iter]))
            x_iter+=1
            y_iter+=1
        elseif first.(x_factors[x_iter])>first.(y_factors[y_iter]) 
            new_vec[2]*=first.(y_factors[y_iter])^last.(y_factors[y_iter])
            y_iter+=1
        elseif first.(x_factors[x_iter])<first.(y_factors[y_iter]) 
            new_vec[1]*=first.(x_factors[x_iter])^last.(x_factors[x_iter])
            x_iter+=1
        else
            println("x_iter = $x_iter, y_iter = $y_iter")
        end
    end
    return new_vec
end

function directions()
    return [[1,0],[-1,0],[0,1],[0,-1]]
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

end #module
