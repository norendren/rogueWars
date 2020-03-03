pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
#include strings.p8

--[[
    loan system?
    encounters
    items
    name character or something? home roguelike
    refactor, token opt
    game over screen
    pretty up intro screen and get scrolling text  
]]

frame=0
scroll=0
scrn = {}
aut = 30
draw_inv_stash = false

function _init()
    -- show_menu()
    show_intro()
    -- show_home_select()
    -- show_navigation()
    -- show_bsl()
    -- show_stash()
    -- show_stash_transfer()
    -- show_transaction()
    -- show_final_transaction()

    p.cursor.nav=nav_menu.adom
    p.cursor.items = items.artifact
    p.cursor.bsl=bsl.buy
    p.cursor.trans=trans_menu.middle
    p.cursor.stash=inv.artifact

    nav_menu.home = nav_menu.adom
    handle_home(p.cursor.nav == nav_menu.home)
    calc_inventory()
    randomize_prices()
    equip_coords()

    
    
    --preprocess intro text
    local curr = 1
    local new_s = ""
    for i=1,#intro do
        if sub(intro,i,i) == "\n" then
            new_s = new_s..sub(intro, curr, i-1).." "
            curr = i+1
        end
    end
    intro = new_s
end

function equip_coords()
    -- inventory
    local x=inv_coords.base_x
    local y=inv_coords.base_y
    local sp=1
    for item in all(inv_map) do
        inv[item].x=x
        inv[item].y=y
        inv[item].sp=sp
        y+= inv_coords.y_off
        sp+=1
    end

    x=stash_coords.base_x
    y=stash_coords.base_y
    sp=1
    for item in all(inv_map) do
        stash[item].x=x
        stash[item].y=y
        stash[item].sp = sp
        y+= stash_coords.y_off
        sp+=1
    end
end

function calc_inventory()
    p.bag.current = 0
    for item,v in pairs(inv) do
        p.bag.current+=v.amt
    end
end

function randomize_prices()
    for k, v in pairs(items) do
        v.curr = flr(rnd(v.high-v.low)+v.low+1)
    end
end

function _update()
    scrn.upd()
end

function hcenter(s)
    return 64-#s*2
end

function _draw()
    cls()
    if draw_inv_stash then
        draw_rects(p.cursor.nav.c)
        local a = aut.." aut"
        print(a,hcenter(a),2,7)

        -- health
        spr(7,32,1)
        print("5", 28, 2, 7)

        draw_inventory(7)
        draw_stash(7)
    end
    --full border
    -- rect(0,0,127,127,14)
    scrn.drw()
end

function show_menu()
    draw_inv_stash = false
    scrn.upd = menu_update
    scrn.drw = menu_draw
end

function menu_update()
    if (btnp(5)) then
        show_intro()
    end
end

function menu_draw()
    print("shopkeeprl", 40, 20, 7)

    if frame < 10 then
        print("press x to start", 30, 100, 7)
    end
end

function show_intro()
    -- todo: create intro texts-- if (btnp(5)) then
    draw_inv_stash = false
    frame = 0
    -- end that show only once for each roguelike
    scrn.upd = intro_update
    scrn.drw = intro_draw
end

function intro_update()
    if (btnp(5)) then
        show_home_select()
    end
end

function intro_draw()
    -- todo: add help text and home roguelike
    local part=sub(intro,1,scroll)
    long_printer(part, 0, 7)
    scroll+=2
    print("press x to play", 30, 100, 7)
end

function show_home_select()
    draw_inv_stash = false
    -- end that show only once for each roguelike
    scrn.upd = home_update
    scrn.drw = home_draw
end
-- holder for home selection
h={curr=1}
function home_draw()
    print("please select a home roguelike", 3, 2, 7)
    local y=35
    local pos=1
    for d in all(nav_map) do
        local title=nav_menu[d].full or nav_menu[d].title
        print(title, hcenter(title),y,nav_menu[d].c)
        h[d] = {x=hcenter(title),y=y,pos=pos}
        pos+=1
        y+=10
    end
    spr(0,h[nav_map[h.curr]].x-10,h[nav_map[h.curr]].y-1)
end

function home_update()
    if btnp(2) and h.curr > 1 then h.curr-=1 end
    if btnp(3) and h.curr < 6 then h.curr+=1 end
    if btnp(5) then 
        nav_menu.home = nav_menu[nav_map[h.curr]]
        show_navigation()
    end
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

function show_navigation()
    draw_inv_stash = true
    scrn.upd = nav_update
    scrn.drw = nav_draw
end

function nav_draw()
    -- dungeon selection
    draw_dungeon_selection(7)

    -- player cursor
    spr(0,p.cursor.nav.x-10,p.cursor.nav.y-1)

    -- home
    local home = nav_menu.home
    spr(10,home.x+#home.title*4+2, home.y-2)

    -- most recent dungeon
    local v=nav_menu.visit
    if v.title != nil then
        if v == nav_menu.home then
            local x=home.x+#home.title*4+2
            spr(9,x+6, home.y-2)
        else
            spr(9,v.x+#v.title*4,v.y-1)
        end
    end
end

function nav_update()
    local curs = p.cursor.nav.pos

    if (btnp(0)) and curs > 3 then
        p.cursor.nav = nav_menu[nav_map[curs-3]]
    end
    if (btnp(1)) and curs <= 3 then
        p.cursor.nav = nav_menu[nav_map[curs+3]]
    end
    if (btnp(2)) and curs > 1 then
        p.cursor.nav = nav_menu[nav_map[curs-1]]
    end
    if (btnp(3)) and curs < 6 then
        p.cursor.nav = nav_menu[nav_map[curs+1]]
    end
    if (btnp(5)) and p.cursor.nav != nav_menu.visit then
        for k,d in pairs(nav_menu) do d.visit = false end
        handle_home(p.cursor.nav == nav_menu.home)
        show_bsl()
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

function pad(i)
    local pad = ""
    if i < 100 then pad=pad.."0" end
    if i < 10 then pad=pad.."0" end
    return pad
end

function draw_inventory(c)
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

function draw_stash(c)
    print("stash", stash_coords.base_x+3, stash_coords.base_y-12, c)
    for k,v in pairs(stash) do
        print(v.disp, v.x+8, v.y, c)
        spr(v.sp,v.x-3,v.y-1)
        print(v.amt, v.x+stash_coords.x_off, v.y, c)
    end
end

function draw_dungeon_selection(c)
    for k,rog in pairs(nav_menu) do
        print(rog.title, rog.x,rog.y,rog.c)
    end
    
end

function show_bsl()
    draw_inv_stash = true
    scrn.drw = bsl_draw
    scrn.upd = bsl_update
end

function bsl_draw()
    draw_prices(7)
    draw_bsl(7)

    -- player cursor
    spr(0,p.cursor.bsl.x-10, bsl_y-1)
end

function bsl_update()
    local curs = p.cursor.bsl.pos
    local map = bsl_map

    if (btnp(0)) and curs > 1 then
        p.cursor.bsl = bsl[map[curs-1]]
    end
    if (btnp(1)) and curs < #map then
        p.cursor.bsl = bsl[map[curs+1]]
    end
    if (btnp(5)) then
        if p.cursor.bsl.title == "leave" then
            aut-=1
            if aut == 0 then
                -- show game over
            end
            nav_menu.visit = p.cursor.nav
            p.cursor.bsl = bsl.buy
            randomize_prices()
            show_navigation() 
        elseif p.cursor.bsl.title == "stash" then
            show_stash()
        else
            show_transaction()
        end
    end
end

function draw_bsl(c)
    for k,v in pairs(bsl) do
            print(v.title,v.x,bsl_y,c)
    end
end

function show_stash()
    draw_inv_stash = true
    scrn.drw = stash_draw
    scrn.upd = stash_update
end

function stash_draw()
    draw_prices(7)
    draw_bsl(7)

    -- indicator for buy/sell mode
    rect(
        p.cursor.bsl.x-3,
        bsl_y-3,
        (p.cursor.bsl.x-3)+#p.cursor.bsl.title*5.5,
        (bsl_y-3) + 10,
        7)
    
    -- player cursor
    local x=p.cursor.stash.x
    local y=p.cursor.stash.y
    rect(x-4,y-2,x+54,y+6,7)
end

function stash_update()
    local pos=p.cursor.stash.pos
    if btnp(0) and in_inventory then
        in_inventory=false
        p.cursor.stash=stash[inv_map[pos]]
    end
    if btnp(1) and not in_inventory then
        in_inventory=true
        p.cursor.stash=inv[inv_map[pos]]
    end
    if btnp(2) and pos >= 1 then
        if pos==1 then pos=7 end
        if in_inventory then
            p.cursor.stash=inv[inv_map[pos-1]]
        else
            p.cursor.stash=stash[inv_map[pos-1]]
        end
    end
    if btnp(3) and pos <= 6 then
        if pos==6 then pos=0 end
        if in_inventory then
            p.cursor.stash=inv[inv_map[(pos+1)]]
        else
            p.cursor.stash=stash[inv_map[(pos+1)]]
        end
    end
    if btnp(4) then
        show_bsl()
    end
    if btnp(5) then
        p.inf_trans.amt = 0
        show_stash_transfer()
    end
end

function show_stash_transfer()
    draw_inv_stash = true
    scrn.drw = stash_transfer_draw
    scrn.upd = stash_transfer_update
end
function stash_transfer_draw()
    -- draw_prices(7)
    -- draw_bsl(7)
    if in_inventory then
        print("transfer "..p.cursor.stash.disp.."s to stash",item_coords.base_x, item_coords.base_y, 7)
        print("⬆️⬇️ = 1",item_coords.base_x, item_coords.base_y+7, 7)
        print("⬅️➡️ = 5",item_coords.base_x, item_coords.base_y+14, 7)
    else
        print("transfer "..p.cursor.stash.disp.."s to inventory",item_coords.base_x, item_coords.base_y, 7)
        print("⬆️⬇️ = 1",item_coords.base_x, item_coords.base_y+7, 7)
        print("⬅️➡️ = 5",item_coords.base_x, item_coords.base_y+14, 7)
    end

    print(p.inf_trans.amt, 62, trans_menu.y, 7)
    
    -- player cursor
    local x=p.cursor.stash.x
    local y=p.cursor.stash.y
    rect(x-4,y-2,x+54,y+6,7)
end

function stash_transfer_update()
    local pos=p.cursor.stash.pos
    local space = p.bag.capacity - p.bag.current
    if(btnp(0)) and p.inf_trans.amt > 1 then 
        if p.inf_trans.amt-5 < 0 then
            p.inf_trans.amt=0
        else     
            p.inf_trans.amt-=5 
        end
    end
    if(btnp(1)) then
        if p.inf_trans.amt + 5 > p.cursor.stash.amt then
            if not in_inventory and p.inf_trans.amt + 5 > space then
                p.inf_trans.amt = space
            else
                p.inf_trans.amt = p.cursor.stash.amt
            end
        else
            if not in_inventory and p.inf_trans.amt + 5 > space then
                p.inf_trans.amt = space
            else
                p.inf_trans.amt+=5 
            end
        end
    end
    if(btnp(2)) then 
        if p.inf_trans.amt + 1 > p.cursor.stash.amt then
            if not in_inventory and p.inf_trans.amt + 5 > space then
                p.inf_trans.amt = space
            else
                p.inf_trans.amt = p.cursor.stash.amt
            end
        else
            if not in_inventory and p.inf_trans.amt + 1 > space then
                p.inf_trans.amt = space
            else
                p.inf_trans.amt+=1
            end
        end
    end
    if(btnp(3)) and p.inf_trans.amt > 1 then p.inf_trans.amt-=1 end

    if(btnp(4)) then show_stash() end

    if(btnp(5)) then
        if in_inventory then
            stash[inv_map[pos]].amt += p.inf_trans.amt
            p.cursor.stash.amt -= p.inf_trans.amt
        else
            inv[inv_map[pos]].amt += p.inf_trans.amt
            p.cursor.stash.amt -= p.inf_trans.amt
        end
        calc_inventory()
        show_bsl()
    end
end

function show_transaction()
    draw_inv_stash = true
    scrn.drw = transaction_draw
    scrn.upd = transaction_update
end

function transaction_draw()
    if p.cursor.bsl.title == "buy" then
        draw_prices(7, true)
    else
        draw_prices(7)
    end
    draw_bsl(7)

    -- indicator for buy/sell mode
    rect(
        p.cursor.bsl.x-3,
        bsl_y-3,
        (p.cursor.bsl.x-3)+#p.cursor.bsl.title*5.5,
        (bsl_y-3) + 10,
        7)
    
    -- player cursor
    spr(0,p.cursor.items.x-10,p.cursor.items.y-1)
end

function transaction_update()
    local curs = p.cursor.items.pos

    if (btnp(0)) and curs > 3 then
        p.cursor.items = items[i_menu_map[curs-3]]
    end
    if (btnp(1)) and curs <= 3 then
        p.cursor.items = items[i_menu_map[curs+3]]
    end
    if (btnp(2)) and curs > 1 then
        p.cursor.items = items[i_menu_map[curs-1]]
    end
    if (btnp(3)) and curs < 6 then
        p.cursor.items = items[i_menu_map[curs+1]]
    end
    if (btnp(5)) then
        show_final_transaction()
    end
    if (btnp(4)) then
        p.cursor.items = items.artifact -- back to baseline
        show_bsl()
    end
end

function show_final_transaction()
    draw_inv_stash = true
    scrn.drw = final_trans_draw
    scrn.upd = final_trans_update
end

function final_trans_draw()
    print(p.cursor.bsl.title.."ing "..p.cursor.items.disp.." for "..p.cursor.items.curr,item_coords.base_x-3, item_coords.base_y, 7)

    -- middle of the road amount
    if p.cursor.bsl.title == "buy" then
        p.inf_trans.buying = true
        trans_menu.middle.amt, trans_menu.all.amt = calc_trans_buy()
    else
        p.inf_trans.selling = true
        trans_menu.middle.amt, trans_menu.all.amt = calc_trans_sell()
    end
    print(trans_menu.middle.amt, trans_menu.middle.x, trans_menu.y)
    print("all("..trans_menu.all.amt..")", trans_menu.all.x, trans_menu.y)
    print("custom", trans_menu.cust.x, trans_menu.y)
    -- player cursor
    spr(0,p.cursor.trans.x-10, trans_menu.y-1)
end

function final_trans_update()
    local curs = p.cursor.trans.pos
    if (btnp(0)) and curs > 1 then
        p.cursor.trans = trans_menu[trans_map[curs-1]]
    end
    if (btnp(1)) and curs < 3 then
        p.cursor.trans = trans_menu[trans_map[curs+1]]
    end
    if (btnp(5)) then
        p.inf_trans.amt = p.cursor.trans.amt
        show_adjust_amt()
    end
    if(btnp(4)) then
        p.inf_trans.buying = false
        p.inf_trans.selling = false
        show_transaction()
    end
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

function calc_trans_sell()
    local mid = flr(inv[p.cursor.items.disp].amt/2)
    local all = inv[p.cursor.items.disp].amt

    return mid, all
end

-- semi helpful debugger
function show_shit()
    scrn.upd = function()
    end

    scrn.drw = function()
        cursor(0)
        color(7)
        for k,v in pairs(bsl) do
            print(k)
        end
    end
end

function show_adjust_amt()
    draw_inv_stash = true
    scrn.upd = adjust_update
    scrn.drw = adjust_draw
end

function adjust_draw()
    print("adjust final amount?",item_coords.base_x-3, item_coords.base_y, 7)
    print("⬆️⬇️ = 1",item_coords.base_x-3, item_coords.base_y+7, 7)
    print("⬅️➡️ = 5",item_coords.base_x-3, item_coords.base_y+14, 7)

    print(p.inf_trans.amt, 62, trans_menu.y, 7)
end

function adjust_update()
    
    if(btnp(0)) and p.inf_trans.amt > 1 then 
        if p.inf_trans.amt-5 < 0 then
            p.inf_trans.amt=0
        else     
            p.inf_trans.amt-=5 
        end
    end
    if(btnp(1)) then 
        if p.inf_trans.amt + 5 > trans_menu.all.amt then
            p.inf_trans.amt = trans_menu.all.amt
        else
            p.inf_trans.amt+=5 
        end
    end
    if(btnp(2)) then 
        if p.inf_trans.amt + 1 > trans_menu.all.amt then
            p.inf_trans.amt = trans_menu.all.amt
        else
            p.inf_trans.amt+=1 
        end
    end
    if(btnp(3)) and p.inf_trans.amt > 1 then p.inf_trans.amt-=1 end

    if(btnp(4)) then show_final_transaction() end

    if(btnp(5)) then
        if p.inf_trans.buying then
            money:buy(p.inf_trans.amt, p.cursor.items.curr)
            inv[p.cursor.items.disp].amt += p.inf_trans.amt
        else
            money:sell(p.inf_trans.amt,p.cursor.items.curr)
            inv[p.cursor.items.disp].amt -= p.inf_trans.amt
        end
        p.inf_trans.buying = false
        p.inf_trans.selling = false
        calc_inventory()
        show_bsl()
    end
end

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

function draw_rects(c)
    -- stash
    rect(0,9,60,73,c)

    -- inventory
    rect(67,9,127,73,c)
    
    -- bottom half
    local title = p.cursor.nav.full or p.cursor.nav.title
    print(title,64-#title*2, bottom_half_y-12)
    rect(0,75,127,127,c)
end

function draw_prices(c, money_check)
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

__gfx__
00000000000cc0000000ccc000044000060000604ffffff4004440000080008000888000000cc000000400000000500000000000000000000000000000000000
00a0000000c77c0000000cc000444400006006000f00f0f0007470000888088800888000000cc000004440000555555500000000000000000000000000000000
00a666600ca77ac00004a0c004444440000660000ffffff00788870008888888008880000004a0000444440005ccccc500000000000000000000000000000000
44a66666c77aa77c004a4000444554440a0660a00f0000f0788888700888888800888000000a400044444440055ccc5500000000000000000000000000000000
00a66660c77aa77c04a400004445544400a00a000ffffff07888887008888888888888800004a0000fffff00005ccc5000000000000000000000000000000000
00a000000ca77ac04a40000004444440040aa0400f0f00f0778887700088888008888800000a40000fcfff000055c55000000000000000000000000000000000
0000000000c77c00a400000000444400400000044ffffff40777770000088800008880000004a0000fff4f000005c50000000000000000000000000000000000
00000000000cc00000000000000440000000000000000000000000000000800000080000000a40000fff4f000005550000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000777000007770777077700000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000770000000070707070700000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000077000007770707070700000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000777000007000707070700000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000070000007770777077700000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000000770777077700770707000000000000000000000000000000000b000000b00000007770777007700000077700000007000007770777000000000000b
b00000007000070070707000707000000000000000000000000000000000b000000b00000007070707070000000070700000070000007000707000000000000b
b00000007770070077707770777000000000000000000000000000000000b000000b00000007700777070000000070700000070000007770707000000000000b
b00000000070070070700070707000000000000000000000000000000000b000000b00000007070707070700000070700000070000000070707000000000000b
b00000007700070070707700707000000000000000000000000000000000b000000b00000007770707077700000077700000700000007770777000000000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00007770777077707770777077700770777007700000000007770000000b000000b00007770777077707770777077700770777007700000000007770000000b
b00007070707007000700700070707000070070000000000007070000000b000000b00007070707007000700700070707000070070000000000007070000000b
b00007770770007000700770077707000070077700000000007070000000b000000b00007770770007000700770077707000070077700000000007070000000b
b00007070707007000700700070707000070000700000000007070000000b000000b00007070707007000700700070707000070000700000000007070000000b
b00007070707007007770700070700770070077000000000007770000000b000000b00007070707007007770700070700770070077000000000007770000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00007070777077007700077000000000000000000000000007770000000b000000b00007070777077007700077000000000000000000000000007770000000b
b00007070707070707070700000000000000000000000000007070000000b000000b00007070707070707070700000000000000000000000000007070000000b
b00007070777070707070777000000000000000000000000007070000000b000000b00007070777070707070777000000000000000000000000007070000000b
b00007770707070707070007000000000000000000000000007070000000b000000b00007770707070707070007000000000000000000000000007070000000b
b00007770707070707770770000000000000000000000000007770000000b000000b00007770707070707770770000000000000000000000000007770000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00007770777077700770777000000000000000000000000007770000000b000000b00007770777077700770777000000000000000000000000007770000000b
b00007070707077707070707000000000000000000000000007070000000b000000b00007070707077707070707000000000000000000000000007070000000b
b00007770770070707070770000000000000000000000000007070000000b000000b00007770770070707070770000000000000000000000000007070000000b
b00007070707070707070707000000000000000000000000007070000000b000000b00007070707070707070707000000000000000000000000007070000000b
b00007070707070707700707000000000000000000000000007770000000b000000b00007070707070707700707000000000000000000000000007770000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00007070777077707770077077000770000000000000000007770000000b000000b00007070777077707770077077000770000000000000000007770000000b
b00007070700070707070707070707000000000000000000007070000000b000000b00007070700070707070707070707000000000000000000007070000000b
b00007070770077707770707070707770000000000000000007070000000b000000b00007070770077707770707070707770000000000000000007070000000b
b00007770700070707000707070700070000000000000000007070000000b000000b00007770700070707000707070700070000000000000000007070000000b
b00007770777070707000770070707700000000000000000007770000000b000000b00007770777070707000770070707700000000000000000007770000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000770077077700770700070000770000000000000000007770000000b000000b00000770077077700770700070000770000000000000000007770000000b
b00007000700070707070700070007000000000000000000007070000000b000000b00007000700070707070700070007000000000000000000007070000000b
b00007770700077007070700070007770000000000000000007070000000b000000b00007770700077007070700070007770000000000000000007070000000b
b00000070700070707070700070000070000000000000000007070000000b000000b00000070700070707070700070000070000000000000000007070000000b
b00007700077070707700777077707700000000000000000007770000000b000000b00007700077070707700777077707700000000000000000007770000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00007770077077707770077077000770000000000000000007770000000b000000b00007770077077707770077077000770000000000000000007770000000b
b00007070707007000700707070707000000000000000000007070000000b000000b00007070707007000700707070707000000000000000000007070000000b
b00007770707007000700707070707770000000000000000007070000000b000000b00007770707007000700707070707770000000000000000007070000000b
b00007000707007000700707070700070000000000000000007070000000b000000b00007000707007000700707070700070000000000000000007070000000b
b00007000770007007770770070707700000000000000000007770000000b000000b00007000770007007770770070707700000000000000000007770000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
b00000000000000000000000000000000000000000000000000000000000b000000b00000000000000000000000000000000000000000000000000000000000b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000022202200022022200000000000000000000000000000000000444044400440044040404440000000000000000000000000000000000b
b000000000000000000020202020202022200000000000000000000000000000000000404040404040400040404000000000000000000000000000000000000b
b000000000000000000022202020202020200000000000000000000000000000000000440044004040400040404400000000000000000000000000000000000b
b000000000000000000020202020202020200000000000000000000000000000000000404040404040404040404000000000000000000000000000000000000b
b000000000000000000020202220220020200000000000000000000000000000000000444040404400444004404440000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b0000000000000000000990009900990099000000000000000000000000000a00000000bb00bb00bb0bbb0bbb0bb00bb0000000000000000000000000000000b
b0000000000000000000909090009000900000000000000000000000000000a6666000b000b0b0b000bbb00b00b0b0b0b000000000000000000000000000000b
b0000000000000000000909090009990999000000000000000000000000044a6666600b000b0b0b000b0b00b00b0b0b0b000000000000000000000000000000b
b0000000000000000000909090000090009000000000000000000000000000a6666000b000b0b0b0b0b0b00b00b0b0b0b000000000000000000000000000000b
b0000000000000000000999009909900990000000000000000000000000000a00000000bb0bb00bbb0b0b0bbb0b0b0bbb000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b0000000000000000000cc00ccc0ccc0c0c0ccc00cc0c0c000000000000000000000000aa00aa0a000aa00aaa0aa000000a0a0aaa00aa0aa00aaa0000000000b
b0000000000000000000c0c0c0000c00c0c0c0c0c000c0c00000000000000000000000a000a0a0a000a0a0a000a0a00000a0a0a0a0a0a0a0a0a000000000000b
b0000000000000000000c0c0cc000c00ccc0ccc0c000cc000000000000000000000000a000a0a0a000a0a0aa00a0a00000aa00aa00a0a0a0a0aa00000000000b
b0000000000000000000c0c0c0000c00c0c0c0c0c000c0c00000000000000000000000a0a0a0a0a000a0a0a000a0a00000a0a0a0a0a0a0a0a0a000000000000b
b0000000000000000000c0c0ccc00c00c0c0c0c00cc0c0c00000000000000000000000aaa0aa00aaa0aaa0aaa0a0a00000a0a0a0a0aa00a0a0aaa0000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb

