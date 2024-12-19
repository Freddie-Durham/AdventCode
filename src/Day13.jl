include("utils.jl")
using .utils

struct Claw_Machine
    A::Vector{Int64}
    B::Vector{Int64}
    prize::Vector{Int64}

    function Claw_Machine(strA,strB,strP)
        A = [parse(Int64,get_X(strA)),parse(Int64,get_Y(strA))]
        B = [parse(Int64,get_X(strB)),parse(Int64,get_Y(strB))]
        prize = get_P(strP)
        P = [parse(Int64,prize[1])+10000000000000,parse(Int64,prize[2])+10000000000000]
        return new(A,B,P)
    end
end

function get_X(str)
    xb = findfirst('+',str)
    xe = findfirst(',',str)

    numstr = ""
    for i in xb+1:xe-1
        numstr = numstr*str[i]
    end
    return numstr
end

function get_Y(str)
    yb = findlast('+',str)
    ye = length(str)

    numstr = ""
    for i in yb+1:ye
        numstr = numstr*str[i]
    end
    return numstr
end

function get_P(str)
    xb = findfirst('=',str)
    yb = findlast('=',str)
    xe = findfirst(',',str)
    ye = length(str)
    numX = ""
    numY = ""
    for i in xb+1:xe-1
        numX = numX*str[i]
    end
    for i in yb+1:ye
        numY = numY*str[i]
    end
    return [numX,numY]
end

function orthonormal_map(vecX,vecY)
    return [1.0 0.0;0.0 1.0]/[vecX[1] vecY[1];vecX[2] vecY[2]]
end

function is_possible(orth,prize)
    new_prize = orth*prize #vec of floats

    #println("$(abs(new_prize[1]-round(new_prize[1]))) : $(abs(new_prize[2]-round(new_prize[2])))")
    tol = 0.00001
    if utils.approx(new_prize[1],round(new_prize[1]),tol) && utils.approx(new_prize[2],round(new_prize[2]),tol)
        return true,new_prize
    else
        
        return false,nothing
    end
end

function main()
    raw_data = readlines("Day13Data.txt")
    claw_machines = Vector{Claw_Machine}()
    for i in 1:4:length(raw_data)
        push!(claw_machines,Claw_Machine(raw_data[i],raw_data[i+1],raw_data[i+2]))
    end
    total_cost = 0
    for (i,claw) in enumerate(claw_machines)
        O = orthonormal_map(claw.A,claw.B)
        poss,min_vec = is_possible(O,claw.prize)
        if poss
            total_cost += min_vec[1]*3+min_vec[2]
        end
    end
    println(total_cost)
end
main()