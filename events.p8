pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function preprocess(s, width)
    -- Format string passed in to be formatted specifically to fit within 
    -- the constraints of the screen
    
    -- default
    local width=width or 30
    local fs=""
    local curr=1
    local space=0

    for i=1,#s do
        if sub(s, i, i) == " " then
            space=i
        end
        if sub(s,i,i)=="\n" then
            if sub(s,i-1,i-1)=="\n" then
                fs=fs.."\n"
            else
                fs=fs..sub(s,curr,i).."\n"
                curr=i+1
            end
        end
        if #sub(s,curr, i) > width then
            fs=fs..sub(s, curr, space).."\n"
            curr = space+1
        end
    end
    if curr < #s then
        fs=fs..sub(s,curr,#s)
    end
    return fs
end

intro=[[you once were a humble merchant, but after a run-in with rodney the rude wizard, you have been cursed with the ability to travel between roguelikes!
capitalist that you are, you must use the time you have left to amass as much wealth as possible, and maybe find a way out of this mess...]]

adom=[[the ancient domains of mystery, little is known about this place of wonder and chaos...
they say most adventurers here die looking for puppies, you consider adding dog collars to your stocks.]]

dcss=[[dungeon crawl stone soup, a wonderful place known by merchants the world over. plenty of wealthy players and much profit to be made
you better hurry though, before you get removed from the game]]

net=[[nethack is a land of many dangers both to players and shopkeepers with items too good to pass up.
players have an annoying habit of constantly asking for the price of things, so you study them well]]

brogue=[[brogue is a world made by making due with what you've got. players pockets overflow with gold they cant spend
hopefully you can make a killing here without getting killed]]

cog=[[you step foot into buzzing machine shop filled with lights and sounds you've never seen.
you break out your trusty label maker hoping to con some of these robots into buying your wares]]

gkh=[[the golden krone hotel, filled with vampires, humans and beasts of all manner
humans aren't normally allowed to sell goods here but you hope the proprietor won't notice]]