pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
#include strings.p8
#include player.p8
#include item_render.p8
#include events.p8

scrn = {}

frame=0
scroll=0
scroll_speed=1

max_aut=20
aut = 20

draw_inv_stash = false
won=false

start_money=800 --ones
end_money=200 --thousands
event_chance=50

function debug()
      -- debug options
      inv.artifact.amt=20
    --   stash.artifact.amt=205
      money.thousands=5
      for k,v in pairs(nav_menu) do
          if v !=nil then
              v.visited=true
          end
      end
    --   event_chance=90
      nav_menu.home = nav_menu.adom
      handle_home(p.cursor.nav == nav_menu.home)
      won=false
      -- end debug
end

function _init()
    init_text()
    p.cursor.nav=nav_menu.adom
    p.cursor.items = items.artifact
    p.cursor.bsl=bsl.buy
    p.cursor.trans=trans_menu.middle
    p.cursor.stash=inv.artifact

    calc_inventory()
    randomize_prices()
    equip_coords()
    reset_player()

    show_menu()


    -- show_intro()
    -- show_home_select()
    -- show_navigation()
    -- show_event()
    -- show_bsl()
    -- show_stash()
    -- show_stash_transfer()
    -- show_trans_select()
    -- show_trans_opts()
    -- show_final_trans()
    -- show_ending()

    -- debug()
end

function init_text()
    intro=preprocess(intro)
    end_offer=preprocess(end_offer)
    end_buy=preprocess(end_buy)
    end_reject=preprocess(end_reject)
    end_no_buy=preprocess(end_no_buy)

    for k,item in pairs(item_events) do
        item.high=preprocess(item.high)
        item.low=preprocess(item.low)
    end

    priest.text=preprocess(priest.text)

    nav_menu.adom.intro=preprocess(adom)
    nav_menu.dcss.intro=preprocess(dcss)
    nav_menu.net.intro=preprocess(net)
    nav_menu.brogue.intro=preprocess(brogue)
    nav_menu.cog.intro=preprocess(cog)
    nav_menu.gkh.intro=preprocess(gkh)
end

function equip_coords()
    -- inventory
    local x=inv_coords.base_x
    local y=inv_coords.base_y
    local sp=1
    for item in all(inv_st_map) do
        inv[item].x=x
        inv[item].y=y
        inv[item].sp=sp
        y+= inv_coords.y_off
        sp+=1
    end

    x=stash_coords.base_x
    y=stash_coords.base_y
    sp=1
    for item in all(inv_st_map) do
        stash[item].x=x
        stash[item].y=y
        stash[item].sp = sp
        y+= stash_coords.y_off
        sp+=1
    end
end

function calc_inventory()
    stash_current=0
    for item,v in pairs(stash) do
        stash_current+=v.amt
    end
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

function _draw()
    cls()
    if draw_inv_stash then
        render_rects(p.cursor.nav.c)
        local a = aut.." turns left"
        print(a,8,2,8)

        -- health

        render_inv(7)
        render_stash(7)
    end
    --full border
    -- rect(0,0,127,127,14)

    scrn.drw()
    frame+=1
    frame=frame%20
end

function show_menu()
    music(0,0,12)

    reset_player()

    draw_inv_stash = false
    scrn.upd = update_menu
    scrn.drw = draw_menu
end

function reset_player()
    aut=20
    won=false
    p.bag.affix=""
    p.bag.capacity=50
    p.bag.current=0

    money.ones=800
    money.thousands=0

    p.cursor.nav=nav_menu.adom
    p.cursor.items = items.artifact
    p.cursor.bsl=bsl.buy
    p.cursor.trans=trans_menu.middle
    p.cursor.stash=inv.artifact

    for k,item in pairs(inv) do
        item.amt=0
    end
    for k,item in pairs(stash) do
        item.amt=0
    end
end

function update_menu()
    if btnp(5) then
        show_intro()
    end
end

function draw_menu()
    sspr(24,9,79,23,25,12)
    sspr(24,33,95,23,18,38)

    local x=25
    local y=75
    for i=1,6 do
        spr(i,x,y)
        x+=14
    end

    if frame < 10 then
        print("press x to start", 30, 100, 7)
    end
    print("intro music by gruber",19,120,7)
end

function show_intro()
    draw_inv_stash=false
    scroll=0

    scrn.upd=update_intro
    scrn.drw=draw_intro
end

function draw_intro()
    local part=sub(intro,1,scroll)
    print(part,0,2,7)
    scroll+=scroll_speed

    if scroll>=#intro and frame>10 then
        print("press x to play", 30, 120, 7)
    end
end

function update_intro()
    -- great short circuit here!
    if scroll < #intro then
        for i=0,5 do
            if btnp(i) then scroll=#intro end
        end
    end
    if btnp(5) and scroll>#intro then
        show_home_select()
    end
end

function show_ending()
    draw_inv_stash = false
    scroll=0

    scrn.drw = draw_ending
    scrn.upd = update_ending
end

end_offer=[[you step through the portal into a familiar place. it is your old shop, but there is only one item on display:
a gleaming wallet bathed in radiance. will you purchase it?]]
end_menu={
    yes={
        text="yes (200,000)",
        x=30,
        y=70,
        pos=1
    },
    no={
        text="no",
        x=30,
        y=80,
        pos=2
    }
}
end_buy=[[you discover that this is none other than the yendorian wallet of immortality. with it you can remove the genies curse and live forever in space between roguelikes
you win!!]]
end_reject=[[the genie comes to collect their due and forces you to become a food merchant for the rest of your life, selling only to the least experienced of players
you have lost the game]]
end_no_buy=[[the genie comes to collect their due and forces you to become a food merchant for the rest of your life, selling only to the least experienced of players
you have ascended in financial disgrace
congrats?]]
ec=end_menu.yes
sy=false
function draw_ending()
    if won then
        local part=sub(end_offer,1,scroll)
        print(part,0,2,7)
        scroll+=scroll_speed

        if scroll>=#end_offer then
            for k,t in pairs(end_menu) do print(t.text,t.x,t.y,7) end
            spr(0,ec.x-10,ec.y-1)
        end
    else
        local part=sub(end_reject,1,scroll)
        print(part,0,3,7)
        scroll+=scroll_speed
        if scroll>=#end_offer then
            if frame<10 then print("game over",hcenter("game over")-5,75,7) end
            print("press x to play again", hcenter("press x to play again")-5,110,7)
        end
    end
end

function update_ending()
    if scroll < #end_offer then
        for i=0,5 do
            if btnp(i) then scroll=#end_offer+1000 end
        end
    end
    if won and scroll>#end_offer then
        if btnp(2) and ec.pos>1 then 
            sfx(0) 
            ec=end_menu.yes 
        end
        if btnp(3) and ec.pos<2 then 
            sfx(0) 
            ec=end_menu.no 
        end
        if btnp(5) then
            show_finale()
            return
        end
    elseif btnp(5) then
        show_menu()
    end
end

function show_finale()
    draw_inv_stash = false
    scroll=0
    if ec==end_menu.yes then
        money:buy(100,2000)
        end_text=end_buy
    else
        end_text=end_no_buy
    end
    scrn.drw = draw_finale
    scrn.upd = update_finale
end

function draw_finale()
    local part=sub(end_text,1,scroll)
    print(part,0,2,7)
    scroll+=scroll_speed
    
    if scroll>=#end_text then
        if frame<10 then print("game over",hcenter("game over")-5,88,7) end
        if end_text==end_buy then
            print("final score: "..money:tostr(),hcenter("final score:")-20,70,7)
        end
        print("press x to play again", hcenter("press x to play again")-5,110,7)
    end
end

function update_finale()
    if scroll < #end_text then
        for i=0,5 do
            if btnp(i) then scroll=#end_text end
        end
    else
    end
    if btnp(5) and scroll>#end_text then 
        show_menu() 
    end
end

function show_home_select()
    draw_inv_stash = false
    -- end that show only once for each roguelike
    scrn.upd = update_home
    scrn.drw = draw_home
end

-- holder for home selection
h={curr=1}
function draw_home()
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

function update_home()
    if btnp(2) and h.curr > 1 then sfx(0) h.curr-=1 end
    
    if btnp(3) and h.curr < 6 then sfx(0) h.curr+=1 end
    
    if btnp(5) then 
        music(-1,500)
        nav_menu.home = nav_menu[nav_map[h.curr]]
        show_navigation()
    end
end

function show_navigation()
    draw_inv_stash = true
    scrn.upd = update_nav
    scrn.drw = draw_nav
end

function draw_nav()
    -- dungeon selection
    render_rog_select(7)

    if won then
        print(yendor.title,yendor.x,yendor.y,yc)
        if frame%3==0 then yc+=1 yc=yc%16 end
        if p.cursor.nav==yendor then render_rects(yc) end
    end

    -- player cursor
    spr(0,p.cursor.nav.x-10,p.cursor.nav.y-1)

    -- home
    local home = nav_menu.home
    spr(10,home.x+#home.title*4+2, home.y-2)

    -- most recent dungeon
    local v=nav_menu.l_visit
    if v.title != nil then
        if v == nav_menu.home then
            local x=home.x+#home.title*4+2
            spr(9,x+8, home.y-2)
        else
            spr(9,v.x+2+#v.title*4,v.y-1)
        end
    end
end

yc=3
yendor={
    title="mysterious portal",
    x=25,
    y=118,
    pos=7,
    c=yc
}
function update_nav()
    local curs = p.cursor.nav.pos

    if btnp(0) and curs > 3 then
        sfx(0)
        p.cursor.nav = nav_menu[nav_map[curs-3]]
    end
    if btnp(1) and curs <= 3 then
        sfx(0)
        p.cursor.nav = nav_menu[nav_map[curs+3]]
    end
    if btnp(2) and curs > 1 then
        sfx(0)
        if p.cursor.nav==yendor then
            p.cursor.nav=nav_menu[nav_map[3]]
        else
            p.cursor.nav = nav_menu[nav_map[curs-1]]
        end
    end
    if btnp(3) and curs <= 6 then
        sfx(0)
        if won and (curs==6 or curs==3) then
            p.cursor.nav = yendor
        elseif p.cursor.nav==yendor then
            return
        elseif curs<6 then
            p.cursor.nav = nav_menu[nav_map[curs+1]]
        end
        
    end
    if btnp(5) and p.cursor.nav != nav_menu.l_visit then
        for k,d in pairs(nav_menu) do d.l_visit = false end

        if p.cursor.nav==yendor then show_ending() return end

        reset_item_colors()
        event=roll_event(event_chance)
        if event!=nil then show_event() return end
        if p.cursor.nav.visited==false then show_rog_intro() return end

        show_bsl()
    end
end

event={}
function show_event()
    draw_inv_stash = false
    scroll=0

    if event!=priest then
        scrn.drw = draw_event
        scrn.upd = update_event
    else
        event:pop_choice()
        scrn.drw = draw_choice_event
        scrn.upd = update_choice_event
    end
end

ce={curr=1}
function draw_choice_event()
    local cur=p.cursor.nav
    local text=event.text
    rect(0,0,127,127,cur.c)

    print("event!!",hcenter("event!!"),4,7)

    if money.thousands == 0 then
        print("$ "..money.ones, 92, 4, 7)
    else
        print("$ "..money:tostr(), 92, 4, 7)
    end

    print(sub(text,1,scroll),4,15,7)
    scroll+=scroll_speed

    local x=0
    local y=65
    local pos=1
    for c in all(event.choice) do
        x=hcenter(c)
        print(c,x,y,7)
        ce[c]={x=x,y=y,pos=pos}
        pos+=1
        y+=7
    end
    spr(0,ce[event.choice[ce.curr]].x-10,ce[event.choice[ce.curr]].y-1)
end

function update_choice_event()
    local len=#event.text
    if scroll < len then
        for i=0,5 do
            if btnp(i) then scroll=len end
        end
    end

    if btnp(2) and ce.curr>1 then sfx(0) ce.curr-=1 end
    if btnp(3) and ce.curr<#event.choice then sfx(0) ce.curr+=1 end

    if btnp(5) and ce.curr==1 and money:afford(event.cost)>0 then 
        event:effect()
        if p.cursor.nav.visited==false then show_rog_intro() return end
        show_bsl()
    elseif btnp(5) and ce.curr==2 then
        if p.cursor.nav.visited==false then show_rog_intro() return end
        show_bsl()
    end
end

function draw_event()
    local cur=p.cursor.nav
    local text=event.text
    rect(0,0,127,127,cur.c)

    print("event!!"..event.type,hcenter("event!!"),4,7)

    print(sub(text,1,scroll),4,15,7)
    scroll+=scroll_speed

    local continue="press x to continue"
    print(continue,hcenter(continue),110,7)
end

function update_event()
    local len=#event.text
    if scroll < len then
        for i=0,5 do
            if btnp(i) then scroll=len end
        end
    end
    if btnp(5) and scroll>len then
        event:effect()
        if p.cursor.nav.visited==false then show_rog_intro() return end
        show_bsl()
    end
end

function show_rog_intro()
    draw_inv_stash = false
    scroll=0

    scrn.drw = draw_rog_intro
    scrn.upd = update_rog_intro
end

function draw_rog_intro()
    local cur=p.cursor.nav
    local title=cur.full or cur.title
    rect(0,0,127,127,cur.c)

    print(title,hcenter(title),4,cur.c)

    print(sub(cur.intro,1,scroll),4,15,7)
    scroll+=scroll_speed

    local continue="press x to continue"
    print(continue,hcenter(continue),110,7)
end

function update_rog_intro()
    local len=#p.cursor.nav.intro
    if scroll < len then
        for i=0,5 do
            if btnp(i) then scroll=len end
        end
    end
    if btnp(5) and scroll>len then
        p.cursor.nav.visited=true
        show_bsl()
    end
end

function show_bsl()
    draw_inv_stash = true
    handle_home(p.cursor.nav == nav_menu.home)
    scrn.drw = draw_bsl
    scrn.upd = update_bsl
end

function draw_bsl()
    render_prices()
    render_bsl(7)

    -- player cursor
    spr(0,p.cursor.bsl.x-10, bsl_y-1)
end

function update_bsl()
    local curs = p.cursor.bsl.pos
    local map = bsl_map

    if btnp(0) and curs > 1 then
        sfx(0)
        p.cursor.bsl = bsl[map[curs-1]]
    end
    if btnp(1) and curs < #map then
        sfx(0)
        p.cursor.bsl = bsl[map[curs+1]]
    end
    if btnp(5) then
        if p.cursor.bsl.title == "leave" then
            aut-=1
            if aut == -1 then show_ending() return end
            if money.thousands >= end_money then won=true end

            nav_menu.l_visit = p.cursor.nav
            p.cursor.bsl = bsl.buy
            randomize_prices()
            show_navigation() 
        elseif p.cursor.bsl.title == "stash" then
            show_stash()
        else
            show_trans_select()
        end
    end
end

function show_stash()
    draw_inv_stash = true
    scrn.drw = draw_stash
    scrn.upd = update_stash
end

function draw_stash()
    render_prices(7)
    render_bsl(7)

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

function update_stash()
    local pos=p.cursor.stash.pos
    if btnp(0) and in_inventory then
        sfx(0)
        in_inventory=false
        p.cursor.stash=stash[inv_st_map[pos]]
    end
    if btnp(1) and not in_inventory then
        sfx(0)
        in_inventory=true
        p.cursor.stash=inv[inv_st_map[pos]]
    end
    if btnp(2) and pos >= 1 then
        sfx(0)
        if pos==1 then pos=7 end
        if in_inventory then
            p.cursor.stash=inv[inv_st_map[pos-1]]
        else
            p.cursor.stash=stash[inv_st_map[pos-1]]
        end
    end
    if btnp(3) and pos <= 6 then
        sfx(0)
        if pos==6 then pos=0 end
        if in_inventory then
            p.cursor.stash=inv[inv_st_map[(pos+1)]]
        else
            p.cursor.stash=stash[inv_st_map[(pos+1)]]
        end
    end
    if btnp(4) then
        show_bsl()
    end
    if btnp(5) then
        p.inf_trans.amt = p.cursor.stash.amt
        show_stash_transfer()
    end
end

function show_stash_transfer()
    draw_inv_stash = true
    scrn.drw = draw_stash_transfer
    scrn.upd = update_stash_transfer
end

function draw_stash_transfer()
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

function update_stash_transfer()
    local pos=p.cursor.stash.pos
    local inv_space = p.bag.capacity - p.bag.current
    local stash_space = stash_cap - stash_current
    if btnp(0) and p.inf_trans.amt > 1 then 
        sfx(0)
        if p.inf_trans.amt-5 < 0 then
            p.inf_trans.amt=0
        else     
            p.inf_trans.amt-=5 
        end
    end
    if btnp(1) then
        sfx(0)
        if p.inf_trans.amt + 5 > p.cursor.stash.amt then
            if not in_inventory and p.inf_trans.amt + 5 >= inv_space then
                p.inf_trans.amt = inv_space
            else
                p.inf_trans.amt = p.cursor.stash.amt
            end
        else
            if not in_inventory and p.inf_trans.amt + 5 > inv_space then
                p.inf_trans.amt = inv_space
            elseif p.inf_trans.amt>=stash_space then
                p.inf_trans.amt=stash_space
            else
                p.inf_trans.amt+=5 
            end
        end
    end
    if btnp(2) then 
        sfx(0)
        if p.inf_trans.amt + 1 > p.cursor.stash.amt then
            if not in_inventory and p.inf_trans.amt + 5 > inv_space then
                p.inf_trans.amt = inv_space
            else
                p.inf_trans.amt = p.cursor.stash.amt
            end
        else
            if not in_inventory and p.inf_trans.amt + 1 > inv_space then
                p.inf_trans.amt = inv_space
            elseif p.inf_trans.amt>stash_space then
                p.inf_trans.amt=stash_space
            else
                p.inf_trans.amt+=1
            end
        end
    end
    if btnp(3) and p.inf_trans.amt > 1 then sfx(0) p.inf_trans.amt-=1 end

    if btnp(4) then show_stash() end

    if btnp(5) then
        if in_inventory then
            stash[inv_st_map[pos]].amt += p.inf_trans.amt
            p.cursor.stash.amt -= p.inf_trans.amt
        else
            inv[inv_st_map[pos]].amt += p.inf_trans.amt
            p.cursor.stash.amt -= p.inf_trans.amt
        end
        calc_inventory()
        show_bsl()
    end
end

function show_trans_select()
    draw_inv_stash = true
    scrn.drw = draw_trans_select
    scrn.upd = update_trans_select
end

function draw_trans_select()
    if p.cursor.bsl.title == "buy" then
        render_prices(7, true)
    else
        render_prices(7)
    end
    render_bsl(7)

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

function update_trans_select()
    local curs = p.cursor.items.pos

    if btnp(0) and curs > 3 then
        sfx(0)
        p.cursor.items = items[item_map[curs-3]]
    end
    if btnp(1) and curs <= 3 then
        sfx(0)
        p.cursor.items = items[item_map[curs+3]]
    end
    if btnp(2) and curs > 1 then
        sfx(0)
        p.cursor.items = items[item_map[curs-1]]
    end
    if btnp(3) and curs < 6 then
        sfx(0)
        p.cursor.items = items[item_map[curs+1]]
    end
    if btnp(5) then
        show_trans_opts()
    end
    if btnp(4) then
        p.cursor.items = items.artifact -- back to baseline
        show_bsl()
    end
end

function show_trans_opts()
    draw_inv_stash = true
    scrn.drw = draw_trans_opts
    scrn.upd = update_trans_opts
end

function draw_trans_opts()
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

function update_trans_opts()
    local curs = p.cursor.trans.pos
    if btnp(0) and curs > 1 then
        sfx(0)
        p.cursor.trans = trans_menu[trans_map[curs-1]]
    end
    if btnp(1) and curs < 3 then
        sfx(0)
        p.cursor.trans = trans_menu[trans_map[curs+1]]
    end
    if btnp(5) then
        p.inf_trans.amt = p.cursor.trans.amt
        show_final_trans()
    end
    if btnp(4) then
        p.inf_trans.buying = false
        p.inf_trans.selling = false
        show_trans_select()
    end
end

function show_final_trans()
    draw_inv_stash = true
    scrn.upd = update_final_trans
    scrn.drw = draw_final_trans
end

function draw_final_trans()
    print("adjust final amount?",item_coords.base_x-3, item_coords.base_y, 7)
    print("⬆️⬇️ = 1",item_coords.base_x-3, item_coords.base_y+7, 7)
    print("⬅️➡️ = 5",item_coords.base_x-3, item_coords.base_y+14, 7)

    print(p.inf_trans.amt, 62, trans_menu.y, 7)
end

function update_final_trans()
    if btnp(0) and p.inf_trans.amt > 1 then 
        sfx(0)
        if p.inf_trans.amt-5 < 0 then
            p.inf_trans.amt=0
        else     
            p.inf_trans.amt-=5 
        end
    end
    if btnp(1) then 
        sfx(0)
        if p.inf_trans.amt + 5 > trans_menu.all.amt then
            p.inf_trans.amt = trans_menu.all.amt
        else
            p.inf_trans.amt+=5 
        end
    end
    if btnp(2) then 
        sfx(0)
        if p.inf_trans.amt + 1 > trans_menu.all.amt then
            p.inf_trans.amt = trans_menu.all.amt
        else
            p.inf_trans.amt+=1 
        end
    end

    if btnp(3) and p.inf_trans.amt > 1 then sfx(0) p.inf_trans.amt-=1 end

    if btnp(4) then show_trans_opts() end

    if btnp(5) then
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

function reset_item_colors()
    for k,i in pairs(items) do
        i.c=7
    end
end

__gfx__
00000000000cc0000000ccc000044000060000604ffffff400444000008000800088800002222220000400000000500000000000000000000000000000000000
00a0000000c77c0000000cc000444400006006000f00f0f000747000088808880088800022222222004440000555555500000000000000000000000000000000
00a666600ca77ac00004a0c004444440000660000ffffff007888700088888880088800009ff1f100444440005ccccc500000000000000000000000000000000
44a66666c77aa77c004a4000444554440a0660a00f0000f078888870088888880088800049fffff044444440055ccc5500000000000000000000000000000000
00a66660c77aa77c04a400004445544400a00a000ffffff07888887008888888888888804ccc3ccc0fffff00005ccc5000000000000000000000000000000000
00a000000ca77ac04a40000004444440040aa0400f0f00f0778887700088888008888800f4cc3c0f0fcfff000055c55000000000000000000000000000000000
0000000000c77c00a400000000444400400000044ffffff407777700000888000088800000c00c000fff4f000005c50000000000000000000000000000000000
00000000000cc0000000000000044000000000000000000000000000000080000008000000f00f000fff4f000005550000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000066666666666000000000666666660000000000066666600006666600000666660066666666666000000000000000000000000000
00000000000000000000000066111111111660000006111111116000000006611111160006111600000611160611111111111600000000000000000000000000
00000000000000000000000061111111111116000006111111116000000661111111160006111600000611160611111111111600000000000000000000000000
00000000000000000000000061111111111116000006111111116000006111111111116006111600000611160611116666666000000000000000000000000000
00000000000000000000000061111666661111600061111111111600006111116611116006111600000611160611160000000000000000000000000000000000
00000000000000000000000061111600006111600061111111111600061111660611116006111600000611160611160000000000000000000000000000000000
00000000000000000000000061111600006111600611111661111160061116000066666006111600000611160611160000000000000000000000000000000000
00000000000000000000000061111600006111600611116006111160611116000000000006111600000611160611160000000000000000000000000000000000
00000000000000000000000061111600061111600611160000611160611160000000000006111600000611160611160000000000000000000000000000000000
00000000000000000000000061111666611116000611160000611160611160000000000006111600000611160611116666666000000000000000000000000000
00000000000000000000000061111111111116000611160000611160611160000000000006111600000611160611111111111600000000000000000000000000
00000000000000000000000061111111111660000611160000611160611160000666666606111600000611160611111111111600000000000000000000000000
00000000000000000000000061111111111600000611160000611160611160000611111606111600000611160611116666666000000000000000000000000000
00000000000000000000000061111666111160000611160000611160611160000611111606111600000611160611160000000000000000000000000000000000
00000000000000000000000061111600611116000611116006111160611160000666111606111600000611160611160000000000000000000000000000000000
00000000000000000000000061111600061116000611111661111160611160000000611606111600000611160611160000000000000000000000000000000000
00000000000000000000000061111600061111600061111111111600611160000000611606111600000611160611160000000000000000000000000000000000
00000000000000000000000061111600006111600061111111111600611116666666111606111166666111160611160000000000000000000000000000000000
00000000000000000000000061111600006111160006111111116000061111111111116006111111111111160611116666666000000000000000000000000000
00000000000000000000000061111600000611116006111111116000061111111111116006111111111111160611111111111600000000000000000000000000
00000000000000000000000061111600000611116006111111116000006111111111116006111111111111160611111111111600000000000000000000000000
00000000000000000000000066666600000666666000666666660000006666666666660000666666666666600066666666666000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000066666666666000000006666666666600000066666666000000666000000000006666666666600666666666660000000000000000
00000000000000000000000061111111111666000061111111111160000611111111600006111600000000061111111111160661111111116600000000000000
00000000000000000000000061111111111111660061111111111160000611111111600006111600000000061111111111160611111111111160000000000000
00000000000000000000000061111111111111116061111666666600000611166111600006111600000000061111666666600611111111111160000000000000
00000000000000000000000061116666661111116061116000000000006111600611600006111600000000061116000000000611116666611116000000000000
00000000000000000000000061116000006611116061116000000000006111600611160006111600000000061116000000000611116000061116000000000000
00000000000000000000000061116000000061116061116000000000006116000061160006111600000000061116000000000611116000061116000000000000
00000000000000000000000061116000000061116061116000000000006116000061160006111600000000061116000000000611116000061116000000000000
00000000000000000000000061116000000061116061116000000000006116000061160006111600000000061116000000000611116000611116000000000000
00000000000000000000000061116000000061116061111666666600061116000061116006111600000000061111666666600611116666111160000000000000
00000000000000000000000061116000000061116061111111111160061160000006116006111600000000061111111111160611111111111160000000000000
00000000000000000000000061116000000061116061111111111160061166666666116006111600000000061111111111160611111111116600000000000000
00000000000000000000000061116000000061116061111666666600061111111111116006111600000000061111666666600611111111116000000000000000
00000000000000000000000061116000000061116061116000000000061111111111116006111600000000061116000000000611116661111600000000000000
00000000000000000000000061116000000061116061116000000000061166666666116006111600000000061116000000000611116006111160000000000000
00000000000000000000000061116000000061116061116000000000611160000006111606111600000000061116000000000611116000611160000000000000
00000000000000000000000061116000000611116061116000000000611160000006111606111600000000061116000000000611116000611116000000000000
00000000000000000000000061116666666111116061116000000000611600000000611606111166666660061116000000000611116000061116000000000000
00000000000000000000000061111111111111116061111666666600611600000000611606111111111116061111666666600611116000061111600000000000
00000000000000000000000061111111111111660061111111111160611600000000611606111111111116061111111111160611116000006111160000000000
00000000000000000000000061111111111666000061111111111160611600000000611606111111111116061111111111160611116000006111160000000000
00000000000000000000000066666666666000000006666666666600666600000000666600666666666660006666666666600666666000006666660000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000006666666666600000000066666666000000000006666660000666660000066666006666666666600000000000000000000000000
00000000000000000000000006611111111166000000611111111600000000661111116000611160000061116061111111111160000000000000000000000000
00000000000000000000000006111111111111600000611111111600000066111111116000611160000061116061111111111160000000000000000000000000
00000000000000000000000006111111111111600000611111111600000611111111111600611160000061116061111666666600000000000000000000000000
00000000000000000000000006111166666111160006111111111160000611111661111600611160000061116061116000000000000000000000000000000000
00000000000000000000000006111160000611160006111111111160006111166061111600611160000061116061116000000000000000000000000000000000
00000000000000000000000006111160000611160061111166111116006111600006666600611160000061116061116000000000000000000000000000000000
00000000000000000000000006111160000611160061111600611116061111600000000000611160000061116061116000000000000000000000000000000000
00000000000000000000000006111160006111160061116000061116061116000000000000611160000061116061116000000000000000000000000000000000
00000000000000000000000006111166661111600061116000061116061116000000000000611160000061116061111666666600000000000000000000000000
00000000000000000000000006111111111111600061116000061116061116000000000000611160000061116061111111111160000000000000000000000000
00000000000000000000000006111111111166000061116000061116061116000066666660611160000061116061111111111160000000000000000000000000
00000000000000000000000006111111111160000061116000061116061116000061111160611160000061116061111666666600000000000000000000000000
00000000000000000000000006111166611116000061116000061116061116000061111160611160000061116061116000000000000000000000000000000000
00000000000000000000000006111160061111600061111600611116061116000066611160611160000061116061116000000000000000000000000000000000
00000000000000000000000006111160006111600061111166111116061116000000061160611160000061116061116000000000000000000000000000000000
00000000000000000000000006111160006111160006111111111160061116000000061160611160000061116061116000000000000000000000000000000000
00000000000000000000000006111160000611160006111111111160061111666666611160611116666611116061116000000000000000000000000000000000
00000000000000000000000006111160000611116000611111111600006111111111111600611111111111116061111666666600000000000000000000000000
00000000000000000000000006111160000061111600611111111600006111111111111600611111111111116061111111111160000000000000000000000000
00000000000000000000000006111160000061111600611111111600000611111111111600611111111111116061111111111160000000000000000000000000
00000000000000000000000006666660000066666600066666666000000666666666666000066666666666660006666666666600000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000066666666666000000006666666666600000066666666000000666000000000006666666666600666666666660000000000000000000000
00000000000000000061111111111666000061111111111160000611111111600006111600000000061111111111160661111111116600000000000000000000
00000000000000000061111111111111660061111111111160000611111111600006111600000000061111111111160611111111111160000000000000000000
00000000000000000061111111111111116061111666666600000611166111600006111600000000061111666666600611111111111160000000000000000000
00000000000000000061116666661111116061116000000000006111600611600006111600000000061116000000000611116666611116000000000000000000
00000000000000000061116000006611116061116000000000006111600611160006111600000000061116000000000611116000061116000000000000000000
00000000000000000061116000000061116061116000000000006116000061160006111600000000061116000000000611116000061116000000000000000000
00000000000000000061116000000061116061116000000000006116000061160006111600000000061116000000000611116000061116000000000000000000
00000000000000000061116000000061116061116000000000006116000061160006111600000000061116000000000611116000611116000000000000000000
00000000000000000061116000000061116061111666666600061116000061116006111600000000061111666666600611116666111160000000000000000000
00000000000000000061116000000061116061111111111160061160000006116006111600000000061111111111160611111111111160000000000000000000
00000000000000000061116000000061116061111111111160061166666666116006111600000000061111111111160611111111116600000000000000000000
00000000000000000061116000000061116061111666666600061111111111116006111600000000061111666666600611111111116000000000000000000000
00000000000000000061116000000061116061116000000000061111111111116006111600000000061116000000000611116661111600000000000000000000
00000000000000000061116000000061116061116000000000061166666666116006111600000000061116000000000611116006111160000000000000000000
00000000000000000061116000000061116061116000000000611160000006111606111600000000061116000000000611116000611160000000000000000000
00000000000000000061116000000611116061116000000000611160000006111606111600000000061116000000000611116000611116000000000000000000
00000000000000000061116666666111116061116000000000611600000000611606111166666660061116000000000611116000061116000000000000000000
00000000000000000061111111111111116061111666666600611600000000611606111111111116061111666666600611116000061111600000000000000000
00000000000000000061111111111111660061111111111160611600000000611606111111111116061111111111160611116000006111160000000000000000
00000000000000000061111111111666000061111111111160611600000000611606111111111116061111111111160611116000006111160000000000000000
00000000000000000066666666666000000006666666666600666600000000666600666666666660006666666666600666666000006666660000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000cc0000000000000ccc000000000044000000000060000600000004ffffff4000000004440000000000000000000000000000
000000000000000000000000000c77c0000000000000cc000000000444400000000006006000000000f00f0f0000000007470000000000000000000000000000
00000000000000000000000000ca77ac00000000004a0c000000004444440000000000660000000000ffffff0000000078887000000000000000000000000000
0000000000000000000000000c77aa77c000000004a4000000000444554440000000a0660a00000000f0000f0000000788888700000000000000000000000000
0000000000000000000000000c77aa77c00000004a400000000004445544400000000a00a000000000ffffff0000000788888700000000000000000000000000
00000000000000000000000000ca77ac00000004a40000000000004444440000000040aa0400000000f0f00f0000000778887700000000000000000000000000
000000000000000000000000000c77c00000000a400000000000000444400000000400000040000004ffffff4000000077777000000000000000000000000000
0000000000000000000000000000cc00000000000000000000000000440000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000077707770777007700770000070700000777007700000077077707770777077700000000000000000000000000000000000
00000000000000000000000000000070707070700070007000000070700000070070700000700007007070707007000000000000000000000000000000000000
00000000000000000000000000000077707700770077707770000007000000070070700000777007007770770007000000000000000000000000000000000000
00000000000000000000000000000070007070700000700070000070700000070070700000007007007070707007000000000000000000000000000000000000
00000000000000000000000000000070007070777077007700000070700000070077000000770007007070707007000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007770770077707770077000007770707007707770077000007770707000000770777070707770777077700000000000000000000000000
00000000000000000000700707007007070707000007770707070000700700000007070707000007000707070707070700070700000000000000000000000000
00000000000000000000700707007007700707000007070707077700700700000007700777000007000770070707700770077000000000000000000000000000
00000000000000000000700707007007070707000007070707000700700700000007070007000007070707070707070700070700000000000000000000000000
00000000000000000007770707007007070770000007070077077007770077000007770777000007770707007707770777070700000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
000100000252003520065200d52000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000600002d75028750227501b7501575012750107500f7500e7500e7501a750247502a7502e7501e700247002b700007000070000700007000070000700007000070000700007000070000700007000070000700
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400002c7252c0152c7152a0252a7152a0152a7152f0152c7252c0152c7152801525725250152a7252a0152072520715207151e7251e7151e7151e715217152072520715207151e7251e7151e7151e7151e715
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020725200152071520015217252101521715210152c7252c0152c7152c0152a7252a0152a7152a015257252501525715250152672526015267153401532725310152d715280152672525015217151c015
__music__
00 02424344
01 02034344
00 02034344
00 02044344
00 05044344
02 05064344

