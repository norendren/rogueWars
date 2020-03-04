pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function hcenter(s)
    return 64-#s*2
end

function vcenter()
    return 61
end
-- iterate over string finding spaces until reaching max index and pick space closest to max index and chop the string
function long_printer(msg, y, col)
    -- TODO: add fancy printing so it scrolls like a cursor
    curr_index = 1
    space = 0
    cursor(0,y)
    color(col)
    s = msg
    for i=1,#s do
        if sub(s, i, i) == " " then
            space = i
        end
        if #sub(s,curr_index, i) >= 32 then
            print(sub(s, curr_index, space))
            curr_index = space+1
        end
    end
    if curr_index < #s then
        print(sub(s,curr_index, #s))
    end
end