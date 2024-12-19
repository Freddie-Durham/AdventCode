include("utils.jl")
using .utils

mutable struct evolved
    start::Int64
    occurence::Int64
    result::Vector{Int64}

    function evolved(s::Int64,o=1)
        val = s
        for _ in 1:5
            s = blink(s)
        end
        return new(val,o,s)
    end
end

function contains(E::Vector{evolved},val::Int64)
    for (i,e) in enumerate(E)
        if e.start == val
            return i
        end
    end
    return 0
end

function rule1()
    return 1
end

function rule2(str)
    half = convert(Int64,length(str)/2)
    num1 = str[1:half]
    num2 = str[1+half:length(str)]
    return parse(Int64,num1),parse(Int64,num2)
end

function rule3(num)
    return num*2024
end

function blink(stones)
    new_stones = Vector{Int64}()
    for stone in stones
        if stone==0
            push!(new_stones,rule1())
        elseif length(string(stone))%2==0
            num1,num2 = rule2(string(stone))
            push!(new_stones,num1)
            push!(new_stones,num2)
        else
            push!(new_stones,rule3(stone))
        end
    end
    return new_stones
end

function get_stones(data)
    return utils.StrtoFloat(split(data),1)
end

function get_evolved(stones)
    ev_st = Vector{evolved}()
    for s in stones
        push!(ev_st,evolved(s))
    end
    return ev_st
end

function step_evolved(evs::Vector{evolved}) #jump forward 5 steps
    new_evs = deepcopy(evs)
    #copy over all 5 blink maps but reset occurences
    for i in eachindex(new_evs)
        new_evs[i].occurence = 0
    end
    for e in evs
        for r in e.result
            index = contains(evs,r)
            if index==0
                push!(new_evs,evolved(r,e.occurence))
            else
                new_evs[index].occurence += e.occurence
            end
        end
    end
    return new_evs
end

function count_evolved(evs::Vector{evolved})
    Σ = 0
    for e in evs
        Σ+=e.occurence*length(e.result)
    end
    return Σ
end

function main()
    filename = "Day11Data.txt"
    raw_data = readlines(filename)
    stones = get_stones(raw_data[1])

    evolution = get_evolved(stones) #5 steps
    
    for _ in 1:14 #20 steps
        evolution = step_evolved(evolution)
    end
    
    println(count_evolved(evolution))

    #=    
    @time for i in 1:25
        stones = blink(stones)
    end
    println("Final length: $(length(stones))")
    =#
end
main()