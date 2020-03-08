pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
top_half_y=25

inv_coords={
    base_x=72,
    base_y=top_half_y,
    x_off=42,
    y_off = 8
}
inv_st_map={"artifact","wand","armor","weapon","scroll","potion"}
in_inventory = true
inv={
    artifact={
        disp="artifact",
        amt=0,
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
function render_inv(c)
    if money.thousands == 0 then
        print("$ "..money.ones, 78, 2, c)
    else
        -- gotta pad the ones in cases where < 100 or < 10
        print("$ "..money:tostr(), 78, 2, c)
    end

    if p.bag.affix == "" then
        print("bag", inv_coords.base_x+1, inv_coords.base_y-12, p.bag.c)
    else
        print(p.bag.affix,inv_coords.base_x-3, inv_coords.base_y-14, p.bag.c)
        print("bag", inv_coords.base_x+1, inv_coords.base_y-7, p.bag.c)
    end

    print(p.bag.current.."/"..p.bag.capacity, inv_coords.base_x+27, inv_coords.base_y-12, c)
    for k,v in pairs(inv) do
        print(v.disp, v.x+8, v.y, c)
        spr(v.sp,v.x-3,v.y-1)
        print(v.amt, v.x+inv_coords.x_off, v.y, c)
    end
end

stash_coords = {
    base_x=5,
    base_y=top_half_y,
    x_off=42,
    y_off = 8
}
stash_cap=100
stash_current=0
stash={
    artifact={
        disp="artifact",
        amt=0,
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
function render_stash(c)
    print("stash", stash_coords.base_x+3, stash_coords.base_y-12, c)
    print(stash_current.."/"..stash_cap, stash_coords.base_x+27, stash_coords.base_y-12, c)
    for k,v in pairs(stash) do
        print(v.disp, v.x+8, v.y, c)
        spr(v.sp,v.x-3,v.y-1)
        print(v.amt, v.x+stash_coords.x_off, v.y, c)
    end
end

money={
    ones=0,
    thousands=0,
    tostr=function(self)
        local s=""
        s = s..self.thousands

        local pad = ""
        if self.ones < 100 then pad=pad.."0" end
        if self.ones < 10 then pad=pad.."0" end
        s = s..pad..self.ones
        return s
    end,
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