pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
bottom_half_y=90

-- intermediary refactor file
function render_rects(c)
    -- stash
    rect(0,9,60,73,c)

    -- inventory
    rect(67,9,127,73,c)
    
    -- bottom half
    local title = p.cursor.nav.full or p.cursor.nav.title
    print(title,64-#title*2, bottom_half_y-12)
    rect(0,75,127,127,c)
end

function render_prices()
    --reset 'em somehow
    local art=items.artifact
    print(art.disp, art.x, art.y,art.c)
    print(art.curr, item_coords.x_off, art.y,art.c)

    local wand=items.wand
    print(wand.disp, wand.x, wand.y,wand.c)
    print(wand.curr, item_coords.x_off, wand.y,wand.c)

    local arm=items.armor
    print(arm.disp, arm.x, arm.y,arm.c)
    print(arm.curr, item_coords.x_off, arm.y,arm.c)

    local weap=items.weapon
    print(weap.disp, weap.x, weap.y,weap.c)
    print(weap.curr, (item_coords.x_off*2)+8, weap.y,weap.c)

    local scroll=items.scroll
    print(scroll.disp, scroll.x, scroll.y,scroll.c)
    print(scroll.curr, (item_coords.x_off*2)+8, scroll.y,scroll.c)

    local pot=items.potion
    print(pot.disp, pot.x, pot.y,pot.c)
    print(pot.curr, (item_coords.x_off*2)+8 , pot.y,pot.c)
end

function render_bsl(c)
    for k,v in pairs(bsl) do
            print(v.title,v.x,bsl_y,c)
    end
end

function render_rog_select(c)
    for k,rog in pairs(nav_menu) do
        print(rog.title, rog.x,rog.y,rog.c)
    end
end

function handle_home(arriving)
    if arriving then
        bsl = {
            stash={
                title="stash",
                x=13,
                pos=1,
            },
            buy={
                title="buy",
                x=44,
                pos=2
            },
            sell={
                title="sell",
                x=68,
                pos=3
            },
            leave={
                title="leave",
                x=98,
                pos=4
            },
        }
        bsl_map = {"stash","buy","sell","leave"}
    else
        bsl = {
            buy={
                title="buy",
                x=27,
                pos=1
            },
            sell={
                title="sell",
                x=52,
                pos=2
            },
            leave={
                title="leave",
                x=82,
                pos=3
            },
        }
        bsl_map = {"buy","sell","leave"}
    end
    p.cursor.bsl = bsl.buy
end

nav_coords = {
    base_x=20,
    base_y=90,
    x_off = 57,
    y_off = 8
}
nav_map={"adom","dcss","net","brogue","cog","gkh"}
nav_menu={
    home={},
    l_visit={},
    adom={
        title="adom",
        full="ancient domains of mystery",
        x=nav_coords.base_x,
        y=nav_coords.base_y,
        c=2,
        pos=1,
        visited=false
    },
    dcss={
        title="dcss",
        full="dungeon crawl stone soup",
        x=nav_coords.base_x,
        y=nav_coords.base_y+nav_coords.y_off,
        c=9,
        pos=2,
        visited=false
    },
    net={
        title="nethack",
        x=nav_coords.base_x,
        y=nav_coords.base_y+nav_coords.y_off*2,
        c=12,
        pos=3,
        visited=false
    },
    brogue={
        title="brogue",
        x=nav_coords.base_x+nav_coords.x_off,
        y=nav_coords.base_y, 
        c=4,
        pos=4,
        visited=false
    },
    cog={
        title="cogmind", 
        x=nav_coords.base_x+nav_coords.x_off,
        y=nav_coords.base_y+nav_coords.y_off,
        c=11,
        pos=5,
        visited=false
    },
    gkh={
        title="gkh",
        full="golden krone hotel",
        x=nav_coords.base_x+nav_coords.x_off,
        y=nav_coords.base_y+nav_coords.y_off*2,
        c=10,
        pos=6,
        visited=false
    }
}

bsl_map = {"buy","sell","leave"}
bsl_y = 115
bsl = {
    buy={
        title="buy",
        x=27,
        pos=1
    },
    sell={
        title="sell",
        x=52,
        pos=2
    },
    leave={
        title="leave",
        x=82,
        pos=3
    },
}

trans_map ={"middle","all","cust"}
trans_menu={
    y=110,
    middle={
        amt=0,
        x=15,
        pos=1
    },
    all={
        amt=0,
        x=42,
        pos=2
    },
    cust={
        amt=0,
        x=90,
        pos=3
    }
}

function low(i)
    return function()
        local mod=rnd(3)+1
        i.c=8
        i.curr=flr(i.low/mod)
    end
end
function high(i)
    return function()
        local mod=rnd(3)+1
        i.c=11
        i.curr=flr(i.high*mod)
    end
end
item_events={
    artifact={
        high=[[adventurers around here act like they have never seen a rare item in their lives. artifacts are selling for crazy high prices!]],
        low=[[a dragon was slain, flooding the market with rare artifacts. time to buy!]]
    },
    wand={
        high=[[an electrical surge exploded everyones wands, they will pay anything to get their hands on one!]],
        low=[[harry potter cosplayers have invaded the dungeon, wands are at an all time low!]]
    },
    armor={
        high=[[dungeon-wide obesity has reached critical levels, adventurers are paying anything for bigger armor]],
        low=[[an enormous vein of mithril has been discovered, armor prices have plummeted!]]
    },
    weapon={
        high=[[dual weilding is the hot new trend, players will pay anything to double their weapon supply!]],
        low=[[a master blacksmith has moved in, forging tons of weapons, diluting the market and lowering prices]]
    },
    scroll={
        high=[[everyone here remembered how to read, and they will pay any amount for scrolls!]],
        low=[[everyone here forgot how to read, scrolls are cheaper than dirt!]]
    },
    potion={ -- not actually eligible cuz they're so crappy
        high=[[the fountains here are literally flowing with health. buy buy buy!]],
        low=[[adventurers drink health potions here like water, they cant get enough of the stuff!]]
    }
}

o={
    text=[[placeholder non item event]],
    effect=function()
        -- local p=items.artifact.low
        -- local mod=rnd(4)
        -- items.artifact.curr=p/mod
    end
}

priest={
    choice={"yes","no"},
    text=[[a wandering priest offers to splash some holy water on your bag]],
    effect=function()
        local bag=p.bag
        if bag.affix=="blessed" then
            return
        end
        bag.affix="blessed"
        bag.c=12
        bag.capacity+=20
    end
}

function roll_event(chance)
    -- 33 percent chance of event, 50 percent chance of *that* being item price, 50/50 high/low
    local ch=rnd(101)
    if ch>chance then
        return nil
    end

    local item_ev=rnd(2)>1
    return priest
    -- return roll_item_event()
    -- return nil
    -- if item_ev then
    --     return roll_item_event()
    -- else
    --     return o
    -- end
end

function roll_item_event()
    -- randomly select item from the list
    local key=item_map[flr(rnd(5)+1)]

    if rnd(2)>1 then
        return {
            text=item_events[key].high,
            effect=high(items[key])
        }
    else
        return {
            text=item_events[key].low,
            effect=low(items[key])
        }
    end
end

item_coords={
    base_x = 12,
    base_y = 88,
    y_off = 7,
    x_off = 53
}
item_map = {"artifact","wand","armor","weapon","scroll","potion"}
items={
    artifact={
        disp="artifact",
        x=item_coords.base_x,
        y=item_coords.base_y,
        low=1500,
        high=3000,
        curr=0,
        pos=1,
        c=7
    },
    wand={
        disp="wand",
        x=item_coords.base_x,
        y=item_coords.base_y+item_coords.y_off,
        low=500,
        high=1400,
        curr=0,
        pos=2,
        c=7
    },
    armor={
        disp="armor",
        x=item_coords.base_x,
        y=item_coords.base_y+item_coords.y_off*2,
        low=100,
        high=450,
        curr=0,
        pos=3,
        c=7
    },
    weapon={
        disp="weapon",
        x=item_coords.base_x+item_coords.x_off+18,
        y=item_coords.base_y,
        low=30,
        high=90,
        curr=0,
        pos=4,
        c=7
    },
    scroll={
        disp="scroll",
        x=item_coords.base_x+item_coords.x_off+18,
        y=item_coords.base_y+item_coords.y_off,
        low=7,
        high=25,
        curr=0,
        pos=5,
        c=7
    },
    potion={
        disp="potion",
        x=item_coords.base_x+item_coords.x_off+18,
        y=item_coords.base_y+item_coords.y_off*2,
        low=1,
        high=6,
        curr=0,
        pos=6,
        c=7
    }
}