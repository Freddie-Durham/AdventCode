include("utils.jl")
using .utils

function get_custom_rules(manual,rules)
    Y_location = utils.vector_of(length(manual)+1,length(rules))

    for (p_num,page) in enumerate(manual)
        for (i,rule) in enumerate(rules)
            if rule[2]==page
                Y_location[i]=p_num
            end
        end
    end
    return Y_location
end

function checkdata(manual,rules)
    Y_location = get_custom_rules(manual,rules)
    for (p_num,page) in enumerate(manual)
        for (i,rule) in enumerate(rules)
            if rule[1] == page && p_num>Y_location[i]
                return false
            end
        end
    end
    return true
end

function fix_manual(manual,rules,count=0)
    Y_location = get_custom_rules(manual,rules)
    for (p_num,page) in enumerate(manual)
        for (i,rule) in enumerate(rules)
            if rule[1] == page && p_num>Y_location[i]
                utils.shift_index!(p_num,Y_location[i],manual)
                break
            end
        end
    end
    if count>50
        println("fail on:")
        println(manual)
        return nothing
    else
        if checkdata(manual,rules)
            return manual
        else
            fix_manual(manual,rules,count+1)
        end
    end
end

function get_banned(manuals,rules)
    banned_list = Vector{Int64}([])
    for (i,manual) in enumerate(manuals)
        if !(checkdata(manual,rules)) #returns true if manual is ok
            push!(banned_list,i)
        end
    end
    return banned_list
end

function get_fixed(manuals,rules,banned_list)
    fixed_list = Vector{Vector{Float64}}([])
    for (i,manual) in enumerate(manuals)
        if i in banned_list 
            push!(fixed_list,fix_manual(manual,rules))
        end
    end
    return fixed_list
end

function main()
    rules = utils.get_data("Day5Rules.txt",'|',1)
    manuals = utils.get_data("Day5Data.txt",',',1)
    
    banned_list = get_banned(manuals,rules)
    fixed_manuals = get_fixed(manuals,rules,banned_list)
    fixed_middles = 0
    for (i,f) in enumerate(fixed_manuals)
        fixed_middles+=f[convert(Int64,1+round((length(f)-1)/2))]
    end
    println(fixed_middles)
end
main()