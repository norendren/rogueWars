pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
#include strings.p8

frame = 0
scrn = {}

function _init()
    show_menu()
    -- show_intro()
    -- show_navigation()print("current "..p.cursor.trans.pos, 0,0,7)
    -- show_bsl()
    -- show_transaction()
    -- show_final_transaction()

    p.cursor.nav=nav_menu["gkh"]
    p.cursor.items = items["weapons"]
    p.cursor.bsl=bsl["buy"]
    p.cursor.trans=trans_menu["middle"]

    randomize_prices()
end

function randomize_prices()
    for k, v in pairs(items) do
        v.curr = flr(rnd(v.high-v.low)+v.low+1)
    end
end

function _update()
    scrn.upd()
end

function _draw()
    cls()
    -- rect(0,0,127,127,14)
    scrn.drw()
end

function show_menu()
    scrn.upd = menu_update
    scrn.drw = menu_draw
end

function menu_update()
    if (btnp(4)) then
        show_intro()
    end
end

function menu_draw()
    print("shopkeeprl", 40, 20, 7)

    if frame < 10 then
        print("press z to start", 30, 100, 7)
    end
    frame += 1
    frame = frame%20
end

function show_intro()
    -- todo: create intro texts-- if (btnp(5)) then
        
    -- end that show only once for each roguelike
    scrn.upd = intro_update
    scrn.drw = intro_draw
end

function intro_update()
    if (btnp(4)) then
        show_navigation()
    end
end

function intro_draw()
    -- todo: add help text and home roguelike
    long_printer(intro, 0, 7)
    print("press z to play", 30, 100, 7)
end

function show_navigation()
    scrn.upd = nav_update
    scrn.drw = nav_draw
end

-- locking y values for top and bottom half
top_half_y=28
bottom_half_y=85

nav_coords = {
    base_x=20,
    base_y=bottom_half_y,
    x_off = 55,
    y_off = 8
}
nav_map = {"gkh","cog","net","brogue","dcss","adom"}
nav_menu = {
    gkh={
        title="gkh",
        x=nav_coords.base_x,
        y=nav_coords.base_y,
        c=10,
        pos=1
    },
    cog={
        title="cogmind", 
        x=nav_coords.base_x,
        y=nav_coords.base_y+nav_coords.y_off,
        c=11,
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
    dcss={
        title="dcss",
        x=nav_coords.base_x+nav_coords.x_off,
        y=nav_coords.base_y+nav_coords.y_off,
        c=9,
        pos=5
    },
    adom={
        title="adom",
        x=nav_coords.base_x+nav_coords.x_off,
        y=nav_coords.base_y+nav_coords.y_off*2,
        c=2,
        pos=6
    }
}

inv_coords = {
    base_x=72,
    base_y=top_half_y,
    x_off=45,
    y_off = 7
}
stash_coords = {
    base_x=5,
    base_y=top_half_y,
    x_off=45,
    y_off = 7
}

-- trying hardcoded explicit cuz sheesh
bsl_map = {"buy","sell","leave"}
bsl = {
    y=112,
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
trans_menu = {
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
    money=5000,
    inf_trans ={
        buying=false,
        selling=false,
        curr_amt=0
    },
    cursor={
        nav={},
        items={},
        bsl={},
        trans={}
    },
    inventory={{disp="artifacts",amt=0},
    {disp="wands",amt=0},
    {disp="armor",amt=30},
    {disp="weapons",amt=0},
    {disp="scrolls",amt=0},
    {disp="potions",amt=0}},

    stash={{disp="artifacts",amt=0},
    {disp="wands",amt=0},
    {disp="armor",amt=0},
    {disp="weapons",amt=0},
    {disp="scrolls",amt=0},
    {disp="potions",amt=0}}
}

function nav_update()
    if (btnp(0)) and p.cursor.nav.pos > 3 then
        p.cursor.nav = nav_menu[nav_map[p.cursor.nav.pos-3]]
    end
    if (btnp(1)) and p.cursor.nav.pos <= 3 then
        p.cursor.nav = nav_menu[nav_map[p.cursor.nav.pos+3]]
    end
    if (btnp(2)) and p.cursor.nav.pos > 1 then
        p.cursor.nav = nav_menu[nav_map[p.cursor.nav.pos-1]]
    end
    if (btnp(3)) and p.cursor.nav.pos < 6 then
        p.cursor.nav = nav_menu[nav_map[p.cursor.nav.pos+1]]
    end
    if (btnp(5)) then
        p.cursor.nav = nav_menu["gkh"] -- back to baseline
        show_bsl()
    end
end

function nav_draw()
    -- player inventory
    draw_inventory(7)

    -- player stash
    draw_stash(7)

    -- dungeon selection
    draw_dungeon_selection(7)

    -- player cursor
    spr(0,p.cursor.nav.x-10,p.cursor.nav.y-1)
end

function draw_inventory(c)
    rect(
        inv_coords.base_x-5,
        inv_coords.base_y-16,
        127,
        70,
        c)

    print("$ "..p.money, inv_coords.base_x-4, 5, c)
    print("inventory", inv_coords.base_x+3, inv_coords.base_y-12, c)
    x = inv_coords.base_x
    y = inv_coords.base_y
    for i=1,#p.inventory do
        print(p.inventory[i].disp, x, y, c)
        print(p.inventory[i].amt, x+inv_coords.x_off, y, c)
        y+= inv_coords.y_off
    end
end

function draw_stash(c)
    rect(
        stash_coords.base_x-5,
        stash_coords.base_y-16,
        (stash_coords.base_x-5)+stash_coords.x_off+13,
        70,
        7)
    print("stash", stash_coords.base_x+3, stash_coords.base_y-12, 7)
    x = stash_coords.base_x
    y = stash_coords.base_y
    for i=1,#p.inventory do
        print(p.stash[i].disp, x, y, 7)
        print(p.stash[i].amt, x+inv_coords.x_off, y)
        y+= stash_coords.y_off
    end
end

function draw_dungeon_selection(c)
    for k,rog in pairs(nav_menu) do
        print(rog.title, rog.x,rog.y,rog.c)
    end
    rect(0,nav_coords.base_y-10,127,127,7)
end

function show_bsl()
    scrn.drw = bsl_draw
    scrn.upd = bsl_update
end

function bsl_draw()
    draw_inventory(7)
    draw_stash(7)

    draw_prices(7)
    draw_bsl(7)

    rect(0,nav_coords.base_y-10,127,127,7)
    
    -- player cursor
    spr(0,p.cursor.bsl.x-10, bsl.y-1)
end

function bsl_update()
    if (btnp(0)) and p.cursor.bsl.pos > 1 then
        p.cursor.bsl = bsl[bsl_map[p.cursor.bsl.pos-1]]
    end
    if (btnp(1)) and p.cursor.bsl.pos < 3 then
        p.cursor.bsl = bsl[bsl_map[p.cursor.bsl.pos+1]]
    end
    if (btnp(5)) then
        if p.cursor.bsl.title == "leave" then
            p.cursor.bsl = bsl["buy"]
            randomize_prices()
            show_navigation() 
        else
            show_transaction()
        end
    end
end

function draw_bsl(c)
    for k,v in pairs(bsl) do
        if k != "y" then -- silly of me to put the y value in there
            print(v.title,v.x,bsl.y,c)
        end
    end
end

function show_transaction()
    scrn.drw = transaction_draw
    scrn.upd = transaction_update
end

function transaction_draw()
    draw_inventory(7)
    draw_stash(7)

    draw_prices(7)
    draw_bsl(7)

    rect(
        p.cursor.bsl.x-3,
        bsl.y-3,
        (p.cursor.bsl.x-3)+#p.cursor.bsl.title*5.5,
        (bsl.y-3) + 10,
        7)

    rect(0,nav_coords.base_y-10,127,127,7)
    
    -- player cursor
    spr(0,p.cursor.items.x-10,p.cursor.items.y-1)
end

function transaction_update()
    if (btnp(0)) and p.cursor.items.pos > 3 then
        p.cursor.items = items[i_menu_map[p.cursor.items.pos-3]]
    end
    if (btnp(1)) and p.cursor.items.pos <= 3 then
        p.cursor.items = items[i_menu_map[p.cursor.items.pos+3]]
    end
    if (btnp(2)) and p.cursor.items.pos > 1 then
        p.cursor.items = items[i_menu_map[p.cursor.items.pos-1]]
    end
    if (btnp(3)) and p.cursor.items.pos < 6 then
        p.cursor.items = items[i_menu_map[p.cursor.items.pos+1]]
    end
    if (btnp(5)) then
        show_final_transaction()
    end
    if (btnp(4)) then
        p.cursor.items = items["artifacts"] -- back to baseline
        show_bsl()
    end
end

function show_final_transaction()
    scrn.drw = final_trans_draw
    scrn.upd = final_trans_update
end

function final_trans_draw()
    draw_inventory(7)
    draw_stash(7)
    
    print("how many "..p.cursor.items.disp.." do you",item_coords.base_x-3, item_coords.base_y, 7)
    print("want to "..p.cursor.bsl.title.."?",item_coords.base_x-3, item_coords.base_y+7, 7)

    -- middle of the road amount
    if p.cursor.bsl.title == "buy" then
        p.inf_trans.buying = true
        --TODO: big todo here to show proper amount and account for capacity
        trans_menu["middle"].amt = flr((p.money/p.cursor.items.curr)/2)
        print(trans_menu["middle"].amt, trans_menu["middle"].x, trans_menu.y)
        trans_menu["all"].amt = flr(p.money/p.cursor.items.curr)
        print("all("..trans_menu["all"].amt..")", trans_menu["all"].x, trans_menu.y)
        print("custom", trans_menu["cust"].x, trans_menu.y)
    end
    -- selling

    rect(0,nav_coords.base_y-10,127,127,7)
    
    -- player cursor
    spr(0,p.cursor.trans.x-10, trans_menu.y-1)
end

function final_trans_update()
    if (btnp(0)) and p.cursor.trans.pos > 1 then
        p.cursor.trans = trans_menu[trans_map[p.cursor.trans.pos-1]]
    end
    if (btnp(1)) and p.cursor.trans.pos < 3 then
        p.cursor.trans = trans_menu[trans_map[p.cursor.trans.pos+1]]
    end
    if (btnp(5)) then
        show_adjust_amt()
    end
    if(btnp(4)) then
        show_transaction()
    end
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
    scrn.upd = adjust_update
    scrn.drw = adjust_draw
end

function adjust_draw()
    draw_inventory(7)
    draw_stash(7)

    print("current "..p.cursor.trans.pos, 0,0,7)
    print("current "..p.cursor.trans.amt, 0,7,7)
    
    print("adjust final amount?",item_coords.base_x-3, item_coords.base_y, 7)
    print("⬆️⬇️ = 1",item_coords.base_x-3, item_coords.base_y+7, 7)
    print("⬅️➡️ = 5",item_coords.base_x-3, item_coords.base_y+14, 7)

    print(p.cursor.trans.amt, 62, trans_menu.y, 7)

    rect(0,nav_coords.base_y-10,127,127,7)
end

function adjust_update()
    if(btnp(0)) and p.cursor.trans.amt > 5 then p.cursor.trans.amt-=5 end
    if(btnp(1)) then p.cursor.trans.amt+=5 end
    if(btnp(2)) then p.cursor.trans.amt+=1 end
    if(btnp(3)) and p.cursor.trans.amt > 1 then p.cursor.trans.amt-=1 end

    if(btnp(4)) then show_final_transaction() end

    if(btnp(5)) then
        --fix all the math here for maxes and negatives
        p.money -= p.cursor.trans.amt*p.cursor.items.curr
        p.inventory[p.cursor.items.pos].amt += p.cursor.trans.amt
        show_bsl()
    end
end

item_coords = {
    base_x = 12,
    base_y = 82,
    y_off = 7,
    x_off = 53
}

-- indexes match the 'pos' field in the items table
i_menu_map = {
    "artifacts",
    "wands",
    "armor",
    "weapons",
    "scrolls",
    "potions"
}

items = {
    artifacts={
        disp="artifacts",
        x=item_coords.base_x,
        y=item_coords.base_y,
        low=1500,
        high=3000,
        curr=0,
        pos=1
    },
    wands={
        disp="wands",
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
    weapons={
        disp="weapons",
        x=item_coords.base_x+item_coords.x_off+18,
        y=item_coords.base_y,
        low=30,
        high=90,
        curr=0,
        pos=4
    },
    scrolls={
        disp="scrolls",
        x=item_coords.base_x+item_coords.x_off+18,
        y=item_coords.base_y+item_coords.y_off,
        low=7,
        high=25,
        curr=0,
        pos=5
    },
    potions={
        disp="potions",
        x=item_coords.base_x+item_coords.x_off+18,
        y=item_coords.base_y+item_coords.y_off*2,
        low=1,
        high=6,
        curr=0,
        pos=6
    }
}

function draw_prices(c)
    -- items
    print(items.artifacts.disp, items.artifacts.x, items.artifacts.y,c)
    print(items.artifacts.curr, item_coords.x_off, items.artifacts.y,c)

    print(items.wands.disp, items.wands.x, items.wands.y,c)
    print(items.wands.curr, item_coords.x_off, items.wands.y,c)

    print(items.armor.disp, items.armor.x, items.armor.y,c)
    print(items.armor.curr, item_coords.x_off, items.armor.y,c)

    print(items.weapons.disp, items.weapons.x, items.weapons.y,c)
    print(items.weapons.curr, (item_coords.x_off*2)+10, items.weapons.y,c)

    print(items.scrolls.disp, items.scrolls.x, items.scrolls.y,c)
    print(items.scrolls.curr, (item_coords.x_off*2)+10, items.scrolls.y,c)

    print(items.potions.disp, items.potions.x, items.potions.y,c)
    print(items.potions.curr, (item_coords.x_off*2)+10, items.potions.y,c)
end


__gfx__
0000000000005000000440004ffffff4000440006000000600000ccc000b000000888000000cc000000000000000000000000000000000000000000000000000
00a0000005555555004444000f00f0f00074470006000060000000cc00bbb00000888000000cc000000000000000000000000000000000000000000000000000
00a6666005ccccc5044444400ffffff0077887700060060000004a0c0bbbbb00008880000004a000000000000000000000000000000000000000000000000000
44a66666055ccc55444554440f0000f077788777000660000004a400bbbbbbb000888000000a4000000000000000000000000000000000000000000000000000
00a66660005ccc50444554440ffffff0788888870a0660a0004a400000bbb000888888800004a000000000000000000000000000000000000000000000000000
00a000000055c550044444400f0f00f07778877700a00a0004a4000000bbb00008888800000a4000000000000000000000000000000000000000000000000000
000000000005c500004444000ffffff077788777040aa0404a40000000bbb000008880000004a000000000000000000000000000000000000000000000000000
0000000000055500000440004ffffff40777777040000004a400000000bbb00000080000000a4000000000000000000000000000000000000000000000000000
