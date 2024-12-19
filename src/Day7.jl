include("utils.jl")
using .utils

struct Calibration
    target::Int64
    nums::Vector{Int64}

    function Calibration(t::Int64,v::Vector{Int64})
        return new(t,v)
    end

    function Calibration(str)
        str_vec = split(str)
        t_string = ""
        for i in 1:length(str_vec[1])-1
            t_string *= str_vec[1][i]
        end
        target = parse(Int64,t_string)
        num_vec = utils.StrtoFloat(str_vec[2:length(str_vec)],1)
        new(target,num_vec)
    end
end

function concat(num::Int64,c::Int64)
    concat_string = string(num,c)
    return parse(Int64,concat_string)
end

function test_operators(C,val = C.nums[1],location=2)
    if val == C.target && location > length(C.nums)
        return true
    elseif val > C.target || location > length(C.nums)
        return false
    else
        return test_operators(C,concat(val,C.nums[location]),location+1)||
               test_operators(C,val*C.nums[location],location+1)|| 
               test_operators(C,val+C.nums[location],location+1)        
    end
end

function main()
    raw_data = readlines("Day7Data.txt")
    calibrations = Vector{Calibration}()
    for raw in raw_data
        push!(calibrations,Calibration(raw))
    end
    total = 0
    for calib in calibrations
        if test_operators(calib)
            total += calib.target
        end
    end
    println(total)
end
main()
