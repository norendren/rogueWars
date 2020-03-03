pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
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

function render_inv(c)
    if money.thousands == 0 then
        print("$ "..money.ones, 92, 2, c)
    else
        -- gotta pad the ones in cases where < 100 or < 10
        print("$ "..money.thousands..pad(money.ones)..money.ones, 92, 2, c)
    end

    if p.bag.affix == "" then
        print("bag", inv_coords.base_x+1, inv_coords.base_y-12, p.bag.c)
    else
        print(p.bag.affix,inv_coords.base_x-3, inv_coords.base_y-14, p.bag.c)
        print("bag", inv_coords.base_x+1, inv_coords.base_y-7, p.bag.c)
    end

    print(p.bag.current.." / "..p.bag.capacity, inv_coords.base_x+25, inv_coords.base_y-12, c)
    for k,v in pairs(inv) do
        print(v.disp, v.x+8, v.y, c)
        spr(v.sp,v.x-3,v.y-1)
        print(v.amt, v.x+inv_coords.x_off, v.y, c)
    end
end

function render_prices(c, money_check)
    -- todo: implement highlighting for inventory space
    money_check = money_check or false

    if money.thousands == 0 and money.ones/items.artifact.curr < 1 and money_check then
        print(items.artifact.disp, items.artifact.x, items.artifact.y,8)
        print(items.artifact.curr, item_coords.x_off, items.artifact.y,8)
    else
        print(items.artifact.disp, items.artifact.x, items.artifact.y,c)
        print(items.artifact.curr, item_coords.x_off, items.artifact.y,c)
    end

    if money.thousands == 0 and money.ones/items.wand.curr < 1 and money_check then
        print(items.wand.disp, items.wand.x, items.wand.y,8)
        print(items.wand.curr, item_coords.x_off, items.wand.y,8)
    else
        print(items.wand.disp, items.wand.x, items.wand.y,c)
        print(items.wand.curr, item_coords.x_off, items.wand.y,c)
    end

    if money.thousands == 0 and money.ones/items.armor.curr < 1 and money_check then
        print(items.armor.disp, items.armor.x, items.armor.y,8)
        print(items.armor.curr, item_coords.x_off, items.armor.y,8)
    else
        print(items.armor.disp, items.armor.x, items.armor.y,c)
        print(items.armor.curr, item_coords.x_off, items.armor.y,c)
    end

    if money.thousands == 0 and money.ones/items.weapon.curr < 1 and money_check then    
        print(items.weapon.disp, items.weapon.x, items.weapon.y,8)
        print(items.weapon.curr, (item_coords.x_off*2)+10, items.weapon.y,8)
    else
        print(items.weapon.disp, items.weapon.x, items.weapon.y,c)
        print(items.weapon.curr, (item_coords.x_off*2)+10, items.weapon.y,c)
    end

    if money.thousands == 0 and money.ones/items.scroll.curr < 1 and money_check then    
        print(items.scroll.disp, items.scroll.x, items.scroll.y,8)
        print(items.scroll.curr, (item_coords.x_off*2)+10, items.scroll.y,8)
    else
        print(items.scroll.disp, items.scroll.x, items.scroll.y,c)
        print(items.scroll.curr, (item_coords.x_off*2)+10, items.scroll.y,c)
    end

    if money.thousands == 0 and money.ones/items.potion.curr < 1 and money_check then    
        print(items.potion.disp, items.potion.x, items.potion.y,8)
        print(items.potion.curr, (item_coords.x_off*2)+10, items.potion.y,8)
    else
        print(items.potion.disp, items.potion.x, items.potion.y,c)
        print(items.potion.curr, (item_coords.x_off*2)+10, items.potion.y,c)
    end
end

function render_bsl(c)
    for k,v in pairs(bsl) do
            print(v.title,v.x,bsl_y,c)
    end
end

function render_stash(c)
    print("stash", stash_coords.base_x+3, stash_coords.base_y-12, c)
    for k,v in pairs(stash) do
        print(v.disp, v.x+8, v.y, c)
        spr(v.sp,v.x-3,v.y-1)
        print(v.amt, v.x+stash_coords.x_off, v.y, c)
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

-- locking y values for top and bottom half
top_half_y=25
bottom_half_y=90

nav_coords = {
    base_x=20,
    base_y=bottom_half_y,
    x_off = 55,
    y_off = 8
}
nav_map={"adom","dcss","net","brogue","cog","gkh"}
nav_menu={
    home={},
    visit={},
    adom={
        title="adom",
        full="ancient domains of mystery",
        x=nav_coords.base_x,
        y=nav_coords.base_y,
        c=2,
        pos=1
    },
    dcss={
        title="dcss",
        full="dungeon crawl stone soup",
        x=nav_coords.base_x,
        y=nav_coords.base_y+nav_coords.y_off,
        c=9,
        pos=2
    },
    net={
        title="nethack",
        x=nav_coords.base_x,
        y=nav_coords.base_y+nav_coords.y_off*2,
        c=12,
        pos=3
    },
    brogue={
        title="brogue",
        x=nav_coords.base_x+nav_coords.x_off,
        y=nav_coords.base_y, 
        c=4,
        pos=4
    },
    cog={
        title="cogmind", 
        x=nav_coords.base_x+nav_coords.x_off,
        y=nav_coords.base_y+nav_coords.y_off,
        c=11,
        pos=5
    },
    gkh={
        title="gkh",
        full="golden krone hotel",
        x=nav_coords.base_x+nav_coords.x_off,
        y=nav_coords.base_y+nav_coords.y_off*2,
        c=10,
        pos=6
    }
}

inv_coords={
    base_x=72,
    base_y=top_half_y,
    x_off=45,
    y_off = 8
}
stash_coords = {
    base_x=5,
    base_y=top_half_y,
    x_off=45,
    y_off = 8
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

-- player data
p = {
    bag={
        affix="",
        c=7,
        capacity=50,
        current=0
    },
    inf_trans ={
        buying=false,
        selling=false,
        amt=0
    },
    cursor={
        nav={},
        items={},
        bsl={},
        trans={},
        stash={}
    }
}

inv_map={"artifact","wand","armor","weapon","scroll","potion"}
in_inventory = true
inv={
    artifact={
        disp="artifact",
        amt=10,
        pos=1
    },
    wand={
        disp="wand",
        amt=0,
        pos=2
    },
    armor={
        disp="armor",
        amt=0,
        pos=3
    },
    weapon={
        disp="weapon",
        amt=0,
        pos=4
    },
    scroll={
        disp="scroll",
        amt=0,
        pos=5
    },
    potion={
        disp="potion",
        amt=0,
        pos=6
    }
}

stash={
    artifact={
        disp="artifact",
        amt=20,
        pos=1
    },
    wand={
        disp="wand",
        amt=80,
        pos=2
    },
    armor={
        disp="armor",
        amt=40,
        pos=3
    },
    weapon={
        disp="weapon",
        amt=0,
        pos=4
    },
    scroll={
        disp="scroll",
        amt=0,
        pos=5
    },
    potion={
        disp="potion",
        amt=0,
        pos=6
    }
}

item_coords = {
    base_x = 12,
    base_y = 88,
    y_off = 7,
    x_off = 53
}

-- indexes match the 'pos' field in the items table
i_menu_map = {
    "artifact",
    "wand",
    "armor",
    "weapon",
    "scroll",
    "potion"
}

items={
    artifact={
        disp="artifact",
        x=item_coords.base_x,
        y=item_coords.base_y,
        low=1500,
        high=3000,
        curr=0,
        pos=1
    },
    wand={
        disp="wand",
        x=item_coords.base_x,
        y=item_coords.base_y+item_coords.y_off,
        low=500,
        high=1400,
        curr=0,
        pos=2
    },
    armor={
        disp="armor",
        x=item_coords.base_x,
        y=item_coords.base_y+item_coords.y_off*2,
        low=100,
        high=450,
        curr=0,
        pos=3
    },
    weapon={
        disp="weapon",
        x=item_coords.base_x+item_coords.x_off+18,
        y=item_coords.base_y,
        low=30,
        high=90,
        curr=0,
        pos=4
    },
    scroll={
        disp="scroll",
        x=item_coords.base_x+item_coords.x_off+18,
        y=item_coords.base_y+item_coords.y_off,
        low=7,
        high=25,
        curr=0,
        pos=5
    },
    potion={
        disp="potion",
        x=item_coords.base_x+item_coords.x_off+18,
        y=item_coords.base_y+item_coords.y_off*2,
        low=1,
        high=6,
        curr=0,
        pos=6
    }
}


-- put this in money?
function calc_trans_sell()
    local mid = flr(inv[p.cursor.items.disp].amt/2)
    local all = inv[p.cursor.items.disp].amt

    return mid, all
end

function calc_trans_buy()
    local all = money:afford(p.cursor.items.curr)
    local mid = flr(all/2)

    local remaining_space = p.bag.capacity - p.bag.current

    if mid > remaining_space then
        if p.bag.capacity == p.bag.current then
            mid = 0
        else
            mid = flr(remaining_space/2)
        end
    end
    if all > remaining_space then
        all = p.bag.capacity - p.bag.current
    end
    return mid,all
end

function pad(i)
    local pad = ""
    if i < 100 then pad=pad.."0" end
    if i < 10 then pad=pad.."0" end
    return pad
end

money = {
    ones=0,
    thousands=5,
    buy=function(self, amt, price)
        for i=1,amt do
            self.ones -= price
            if self.ones < 0 then
                self.thousands -= abs(flr(self.ones/1000))
                self.ones = abs(self.ones % 1000)
            end
        end
    end,
    sell=function(self, amt, price)
        for i=1,amt do
            self.ones += price
            if flr(self.ones/1000) > 0 then
                self.thousands += flr(self.ones/1000)
                self.ones = self.ones % 1000
            end
        end
    end,
    afford=function(self, price)
        local have_money = false
        if self.ones > 0 or self.thousands > 0 then
            have_money = true
        else
            return 0
        end

        local amt = 0
        local ones = self.ones
        local thousands = self.thousands
        
        while have_money do
            ones -= price
            if ones <= 0 and thousands == 0 then
                return amt
            else
                thousands -= abs(flr(ones/1000))
                ones = abs(ones % 1000)
                if thousands < 0 then
                    return amt
                end
            end
            amt += 1
        end
    end
}