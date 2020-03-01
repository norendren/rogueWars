pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
#include strings.p8

frame = 0
scrn = {}

function _init()
    -- show_menu()
    -- show_navigation()
    -- show_intro()
    show_roguelike()
    init_prices()
end

function init_prices()
    for k, v in pairs(items) do
        v.curr = flr(rnd(v.high-v.low)+v.low+1)
    end
end

function _update()
    scrn.upd()
end

function _draw()
    scrn.drw()
end

function show_menu()
    cls()
    scrn.upd = menu_update
    scrn.drw = menu_draw
end

function menu_update()
    if (btnp(4)) then
        show_intro()
    end
end

function menu_draw()
    cls()
    print("shopkeeprl", 40, 20, 7)

    if frame < 10 then
        print("press z to start", 30, 100, 7)
    end
    frame += 1
    frame = frame%20
end

function show_intro()
    cls()
    scrn.upd = intro_update
    scrn.drw = intro_draw
end

function intro_update()
    if (btnp(4)) then
        show_navigation()
    end
end

function intro_draw()
    long_printer(intro, 0, 7)
    print("select home roguelike", 0, 90, 7)
    print("add some button help", 0, 90, 7)
    print("press z to play", 30, 100, 7)
end

function show_navigation()
    cls()
    scrn.upd = nav_update
    scrn.drw = nav_draw
end

-- Locking y values for top and bottom half
top_half_y=28
bottom_half_y=85

nav_coords = {
    base_x=20,
    base_y=bottom_half_y,
    x_off = 55,
    y_off = 8
}

nav_menu = {
    {{
        title="gkh",
        x=nav_coords.base_x,
        y=nav_coords.base_y,
        c=10
    },{
        title="cogmind", 
        x=nav_coords.base_x,
        y=nav_coords.base_y+nav_coords.y_off,
        c=11
    },{
        title="nethack",
        x=nav_coords.base_x,
        y=nav_coords.base_y+nav_coords.y_off*2,
        c=12
    }},
    {{
        title="brogue",
        x=nav_coords.base_x+nav_coords.x_off,
        y=nav_coords.base_y, 
        c=4
    },{
        title="dcss",
        x=nav_coords.base_x+nav_coords.x_off,
        y=nav_coords.base_y+nav_coords.y_off,
        c=9
    },{
        title="adom",
        x=nav_coords.base_x+nav_coords.x_off,
        y=nav_coords.base_y+nav_coords.y_off*2,
        c=2
    }}
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

p = {
    cursor={
        nav={
            x=1,
            y=1
        },
        items={
            
        }
    },
    inventory={{disp="artifacts",amt=0},
    {disp="wands",amt=0},
    {disp="armor",amt=0},
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
    if (btnp(0)) and p.cursor.nav.x > 1 then
        p.cursor.nav.x -= 1
    end
    if (btnp(1)) and p.cursor.nav.x < #nav_menu then
        p.cursor.nav.x += 1
    end
    if (btnp(2)) and p.cursor.nav.y > 1 then
        p.cursor.nav.y -= 1
    end
    if (btnp(3)) and p.cursor.nav.y < #nav_menu[p.cursor.nav.x] then
        p.cursor.nav.y += 1
    end
    if (btnp(5)) then
        show_roguelike()
    end
end

function nav_draw()
    cls()
    rect(0,0,127,127,14)
    -- player inventory
    draw_inventory(7)

    -- player stash
    draw_stash(7)

    -- dungeon selection
    draw_dungeon_selection(7)

    -- player cursor
    local curs_x = nav_menu[p.cursor.nav.x][p.cursor.nav.y].x 
    local curs_y = nav_menu[p.cursor.nav.x][p.cursor.nav.y].y
    spr(0,curs_x-10,curs_y-1)
end

function draw_inventory(c)
    rect(
        inv_coords.base_x-5,
        inv_coords.base_y-16,
        (inv_coords.base_x-5)+inv_coords.x_off+13,
        70,
        c)
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
    x = nav_coords.base_x
    y = nav_coords.base_y
    for i=1,#nav_menu do
        for z=1,#nav_menu[i] do
            item = nav_menu[i][z]
            print(item.title, item.x, item.y, item.c)
        end
    end
    rect(0,nav_coords.base_y-10,127,115,7)
end

function show_roguelike()
    cls()
    scrn.drw = roguelike_draw
    scrn.upd = roguelike_update
end

function roguelike_draw()
    -- TODO: create intro texts that show only once for each roguelike
    cls()
    draw_inventory(7)
    draw_stash(7)

    draw_prices(7)
end

function roguelike_update()

end

item_coords ={
    base_x = 8,
    base_y = 85,
    y_off = 7,
    x_off = 53
}

items = {
    artifacts={
        disp="artifacts",
        x=item_coords.base_x,
        y=item_coords.base_y,
        low=1500,
        high=3000,
        curr=0
    },
    wands={
        disp="wands",
        x=item_coords.base_x,
        y=item_coords.base_y+item_coords.y_off,
        low=500,
        high=1400,
        curr=0
    },
    armor={
        disp="armor",
        x=item_coords.base_x,
        y=item_coords.base_y+item_coords.y_off*2,
        low=100,
        high=450,
        curr=0
    },
    weapons={
        disp="weapons",
        x=item_coords.base_x+item_coords.x_off+22,
        y=item_coords.base_y,
        low=30,
        high=90,
        curr=0
    },
    scrolls={
        disp="scrolls",
        x=item_coords.base_x+item_coords.x_off+22,
        y=item_coords.base_y+item_coords.y_off,
        low=7,
        high=25,
        curr=0
    },
    potions={
        disp="potions",
        x=item_coords.base_x+item_coords.x_off+22,
        y=item_coords.base_y+item_coords.y_off*2,
        low=1,
        high=6,
        curr=0
    }
}

function draw_prices(c)
    print(items.artifacts.disp, items.artifacts.x, items.artifacts.y)
    print(items.artifacts.curr, item_coords.x_off-5, items.artifacts.y)

    print(items.wands.disp, items.wands.x, items.wands.y)
    print(items.wands.curr, item_coords.x_off-5, items.wands.y)

    print(items.armor.disp, items.armor.x, items.armor.y)
    print(items.armor.curr, item_coords.x_off-5, items.armor.y)

    print(items.weapons.disp, items.weapons.x, items.weapons.y)
    print(items.weapons.curr, (item_coords.x_off*2)+8, items.weapons.y)

    print(items.scrolls.disp, items.scrolls.x, items.scrolls.y)
    print(items.scrolls.curr, (item_coords.x_off*2)+8, items.scrolls.y)

    print(items.potions.disp, items.potions.x, items.potions.y)
    print(items.potions.curr, (item_coords.x_off*2)+8, items.potions.y)

    -- player cursor
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
