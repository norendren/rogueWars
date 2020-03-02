pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
intro = [[
you once were a humble merchant, but after a run-in with
rodney the rude wizard, you have been cursed with the ability
to travel between roguelikes! capitalist that you are, you
must use the time you have left to amass as much wealth as
possible, and maybe find a way out of this mess...
]]

practice = [[
the quick brown fox jumps over the lazy dog
the quick brown fox jumps over the lazy dog the quick brown
fox jumps over the lazy dog the quick brown fox jumps over
the lazy dog the quick brown fox jumps over the lazy dog the
quick brown fox jumps over the lazy dog
]]
-- iterate over string finding spaces until reaching max index and pick space closest to max index and chop the string
function long_printer(msg, y, col)
    -- TODO: add fancy printing so it scrolls like a cursor
    curr_index = 1
    space = 0
    cursor(0,y)
    color(col)
    
    s = msg
    
    --preprocess
    curr = 1
    new_s = ""
    for i=1,#msg do
        if sub(msg,i,i) == "\n" then
            new_s = new_s..sub(msg, curr, i-1).." "
            curr = i+1
        end
    end
    if #new_s > 1 then s = new_s end
    
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