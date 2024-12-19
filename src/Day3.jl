include("utils.jl")
using .utils

function is_numeric(str)
    if str=='0'||str=='1'||str=='2'||str=='3'||
        str=='4'||str=='5'||str=='6'||str=='7'||
        str=='8'||str=='9'
        return true
    else
        return false
    end
end

function is_mul(txt,strt,fnsh)
    if txt[strt+1]=='u' && txt[strt+2]=='l' && txt[strt+3]=='('
        state = "first_num"
        first_num = ""
        second_num = ""
        for i in strt+4:fnsh
            if state == "first_num" 
                if isnumeric(txt[i])
                    first_num = first_num*txt[i]
                else
                    if txt[i] == ',' && first_num != ""
                        first_num=parse(Float64,first_num)
                        if i!= fnsh
                            i+=1
                            state = "second_num"
                        else
                            #println("Fail: txt too short")
                            return 0
                        end
                    else
                        #println("Fail: no comma")
                        return 0
                    end
                end
            elseif state == "second_num"
                if isnumeric(txt[i])
                    second_num = second_num*txt[i]
                else
                    if txt[i] == ')' && second_num != "" 
                        second_num=parse(Float64,second_num)
                        return first_num*second_num
                    else
                        #println("Fail: no end bracket")
                        return 0
                    end
                end
            end
        end
    end
    return 0
end

function is_do(txt,strt,fnsh)
    if fnsh-strt > 2
        if txt[strt:strt+3]=="do()"
            return "do"
        elseif fnsh-strt > 5 && txt[strt:strt+6]=="don't()"
            return "dont"
        end
    end
    return "fail"
end

function main()
    txt = readlines("Day3Data.txt")
    count = 0
    do_dont = 1
    for t in txt
        for (i,str) in enumerate(t)
            if str=='m'
                count += do_dont*is_mul(t,i,min(i+11,length(t)))
            elseif str=='d'
                state = is_do(t,i,min(i+6,length(t)))
                if state == "do"
                    do_dont = 1
                elseif state == "dont"
                    do_dont = 0
                end
            end
        end
    end
    println("Count is: $count")
end
main()

