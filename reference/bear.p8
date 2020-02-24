pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--main

--todo
-- tune ending score
-- add score?

--cheats/debug
--starting_season="autumn"
--no_hunger=true
--no_hurt=true
--skip_title=true
--show_turn=true
--test_ending=true
--debug_char=true

c={
 x=0,
 y=0,
 
 shakex=0,
 shakey=0,
 
 shake=function(self,x,y)
  if (x) self.shakex=x
  if (y) self.shakey=y
 end,
 
 update=function(self)
  self.shakex*=0.8
 	self.shakey*=0.8
 	local shakex=rnd(flr(abs(self.shakex)))
  if (self.shakex<0) shakex=-shakex
  self.x+=shakex
  
  local shakey=rnd(flr(abs(self.shakey)))
  if (self.shakey<0) shakey=-shakey
  self.y+=shakey
 end,
}

function show_scene(s,out_speed,in_speed)
 fade_out_speed=out_speed or 1
 fade_in_speed=in_speed or 1
 
 if not scene then
  scene=s
  scene:init()
  fade_in=15*fade_in_speed
 else
  next_scene=s
  fade_out=0
 end
end

function _init()
 palt(0,false)
 palt(14,true)
 frame=0
 if test_ending then
  p={}
  p.hp=1
  p.food=40
  show_scene(ending)
 elseif skip_title then
  show_scene(game)
 else
  show_scene(title,0,2)
 end
end

function _update()
 c.x=0
 c.y=0
 
 if fade_out then
  fade_out+=1
  fade(fade_out/fade_out_speed)
  if fade_out==15*fade_out_speed then
   fade_out=nil
   fade_in=15*fade_in_speed
   scene=next_scene
   scene:init()
   next_scene=nil
  end
 elseif fade_in then
  fade_in-=1
  fade(fade_in/fade_in_speed)
  if fade_in==0 then
   fade_in=nil
   fade(0)
  end
 end
 
 --if next_scene then
--  scene=next_scene
 -- next_scene=nil
 -- scene:init()
 --end
 
 frame+=1
 frame=frame%20
 if (scene) scene:update()
 c:update()
end

function _draw()
 scene:draw()
end

function p_center(str,x,y,c)
 if (c) color(c)
 local w=#str*4
 x=mid(1,x-w/2,128-w)
 print(str,x,y)
end

function blink()
 return frame<10
end

function is_fading()
 return fade_in or fade_out
end

--fade table generated with
--http://kometbomb.net/pico8/fadegen.html
local fadetable={
 {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
 {1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
 {2,2,2,2,2,2,1,1,1,0,0,0,0,0,0},
 {3,3,3,3,3,3,1,1,1,0,0,0,0,0,0},
 {4,4,4,2,2,2,2,2,1,1,0,0,0,0,0},
 {5,5,5,5,5,1,1,1,1,1,0,0,0,0,0},
 {6,6,13,13,13,13,5,5,5,5,1,1,1,0,0},
 {7,6,6,6,6,13,13,13,5,5,5,1,1,0,0},
 {8,8,8,8,2,2,2,2,2,2,0,0,0,0,0},
 {9,9,9,4,4,4,4,4,4,5,5,0,0,0,0},
 {10,10,9,9,9,4,4,4,5,5,5,5,0,0,0},
 {11,11,11,3,3,3,3,3,3,3,0,0,0,0,0},
 {12,12,12,12,12,3,3,1,1,1,1,1,1,0,0},
 {13,13,13,5,5,5,5,1,1,1,1,1,0,0,0},
 {14,14,14,13,4,4,2,2,2,2,2,1,1,0,0},
 {15,15,6,13,13,13,5,5,5,5,5,1,1,0,0}
}

function fade(i)
 for c=0,15 do
  if flr(i+1)>=16 then
   pal(c,0)
  else
   pal(c,fadetable[c+1][flr(i+1)])
  end
 end
end

function rnd_list(list)
 local cnt=#list
 if cnt==0 then
  return nil
 end
 
 local e=list[1+flr(rnd(cnt))]
 del(list,e)
 return e
end
-->8
--game

game={}

game.init=function(self)
 self.finished=false
 
 w={}
 w.width=16
 w.height=15
 w.season=starting_season or
          "spring"
 w.turn=1
 
 cls()
 p_center("generating forest",64,62,7)
 gen_map()
  
 sflower=spawner(1,2,spawn_flower)
 sberry=spawner(5,2,spawn_berry)
 swbush=spawner(1,3,wilt_bush)
 stree=spawner(10,4,spawn_cone)
 sfish=spawner(45,70,spawn_fish)
 sjack=spawner(80,39,spawn_jack)
 shunter=spawner(10,40,spawn_hunter)
 ssnow=spawner(2,1,spawn_snow)
 sden=spawner(12,1,open_den)
 
 tiles={}
 mobiles={}
 
 for ix=0,w.width-1 do
  tiles[ix]={}
  for iy=0,w.height-1 do
   local t=create_tile(ix,iy)
   tiles[ix][iy]=t
 
   local tid=mget(ix,iy)
   t.solid=fget(tid,0)
   t.water=fget(tid,1)
   t.basic=tid==16
   t.house=tid==32
   
   t.spr=16
   if tid==1 then
    local den=create_den(ix,iy)
    den:open()
    create_player(ix,iy)
   elseif tid==34 then
    create_den(ix,iy)
   elseif tid==40 then
    create_tree(ix,iy)
   elseif tid==56 then
    create_bush(ix,iy)
   elseif tid==24 then
    create_flower(ix,iy)
   elseif tid==32 then
    --house
    local s=create_static(ix,iy,32)
    s.solid=true
    s.freeze=function(self)
     self.sprite=48
    end
   elseif tid==33 then
    --rock
    local s=create_static(ix,iy,33)
    s.solid=true
    s.flip=false
    s.freeze=function(self)
     self.sprite=49
    end
   else
    t.spr=tid
   end
  end
 end
 
 create_txt()
 sfx(4)
end

function tick_world()
 if w.season=="spring" then   
  sfish:update()
  if (w.turn<80) sflower:update()
  sjack:update()
  
  if w.turn==100 then
   w.turn=0
   w.season="summer"
  end
  
 elseif w.season=="summer" then
  sfish:update()
  if (w.turn<60) sberry:update()
  sjack:update()
  
  if w.turn==100 then
   w.turn=0
   w.season="autumn"
  end
  
 elseif w.season=="autumn" then
  sfish:update()
  shunter:update()
  swbush:update()
  stree:update()
  if (w.turn>75) ssnow:update()
  
  if w.turn==100 then
   w.turn=0
   w.season="winter"
  end
 elseif w.season=="winter" then
  ssnow:update()
  sden:update()
 end
 
 foreach_tile(function(t)
  if (t.static and t.static.tick) t.static:tick()
 end)
 
 for e in all(mobiles) do
  if (e.tick) e:tick()
 end
 
 w.turn+=1
end

function tick(dx,dy) 
 p:move(dx,dy)
 
 tick_world()
 
 if w.season=="winter" and
    p.entered_den then
  show_scene(ending,16)
  game.finished=true
  game.auto_tick_cnt=8
  sfx(4)
 end
 
 if p.food==0 then
  p.spr=3
  show_scene(ending,4)  
 end
end

game.update=function(self)
 if not is_fading() and
    p.food>0 and
    p.hp>0 then
    
  if btnp(0) then
   tick(-1,0)
   p.flip=false
  elseif btnp(1) then
   tick(1,0)
   p.flip=true
  elseif btnp(2) then tick(0,-1)
  elseif btnp(3) then tick(0,1)
  end
 end
 
 txt:update()
 
 if game.finished then
  game.auto_tick_cnt-=1
  if game.auto_tick_cnt==0 then
   tick_world()
   game.auto_tick_cnt=8
  end
 end
 
 --debug
 if debug_char then
  if (btnp(4)) spawn_jack()
  if (btnp(5)) spawn_hunter()
 end
end

game.draw=function(self)
 cls()
 camera(c.x,c.y-8)
 
 foreach_tile(function(t)
  spr(t.spr,t.x*8,t.y*8)
  if (t.static) t.static:draw()
 end)
 
 p:draw()
 
 for e in all(mobiles) do
  spr(e.spr,e.x*8,e.y*8,1,1,e.flip)
 end
 
 camera()
 color(7)
 if p.food>5 or blink() then
  print("food "..p.food,1,1)
 end
 
 if show_turn then
  
  p_center("--"..sub(w.season,1,2).." "..w.turn.."--",64,1)
 else
  p_center("--"..w.season.."--",64,1)
 end
 
 if p.hp==0 then
  print("dead",112,1)
 elseif p.hp==1 then
  if (blink()) print("wounded",100,1)
 elseif p.food<=5 then
  if (blink()) print("starving",96,1)
 else
  print("healthy",100,1)
 end
 
 camera(c.x,c.y-8)
 txt:draw()
end

--------------------------------
--utils
--------------------------------

function spawner(initial,
                 interval,
                 func)
 local s={}
 s.interval=interval
 s.cnt=initial
 s.func=func
 s.update=function(self)
  self.cnt-=1
  if self.cnt==0 then
   func()
   self.cnt=self.interval
  end
 end 
 return s
end

patch_pattern={
 etet=0,
 ttet=1,
 teet=2,
 eeee=3,
 ettt=16,
 tttt=17,
 tett=18,
 eett=19,
 ette=32,
 ttte=33,
 tete=34,
 ttee=35,
 etee=48,
 teee=49,
 eeet=50,
 eete=51
}

function create_tile(x,y) 
 local t={}
 t.x=x
 t.y=y
 t.snow=0
 t.snow_cd=0

 t.add_snow=function(self)
  if self.snow==0 then
   self.snow=1
   self.spr=17
  elseif self.snow==1 then
   self.snow=2
   self:render_snow()
   self:render_neighbor(-1,0)
   self:render_neighbor(1,0)
   self:render_neighbor(0,-1)
   self:render_neighbor(0,1)
   
   if self.static and
      self.static.freeze then
    self.static:freeze()
    self.static.frozen=true
   end
  end
  self.snow_cd=5
 end
 
 t.clear_snow=function(self)
  if self.snow>1 then
   self.snow-=1
   self.spr=16+self.snow
   self:render_neighbor(-1,0)
   self:render_neighbor(1,0)
   self:render_neighbor(0,-1)
   self:render_neighbor(0,1)
  end
  self.snow_cd=5
 end
    
 t.is_solid=function(self)
  if (self.solid) return true
  if (self.static and self.static.solid) return true
  if (p.x==self.x and p.y==self.y) return true
  if (get_mobile(self.x,self.y)) return true
  return false
 end
 
 t.render_snow=function(self)
  
  local pattern=""
  
  pattern=pattern..self:check_snow(-1,0)
  pattern=pattern..self:check_snow(1,0)
  pattern=pattern..self:check_snow(0,-1)
  pattern=pattern..self:check_snow(0,1)
  
  local sprite=patch_pattern[pattern]
  if sprite then
   self.spr=76+sprite
  else
   self.spr=75
  end
 end
 
 t.check_snow=function(self,dx,dy)
  local t=get_tile(self.x+dx,self.y+dy)
  if not t or t.snow==2 then
   return "t"
  else
   return "e"
  end
 end
 
 t.render_neighbor=function(self,dx,dy)
  local t=get_tile(self.x+dx,self.y+dy)
  if (t and t.snow==2) t:render_snow()
 end
 
 return t  
end

function get_tile(x,y)
 if x<0 or y<y or
    x>=w.width or
    y>=w.height then
  return nil
 end
 
 return tiles[x][y]
end

function foreach_tile(func)
 for ix=0,w.width-1 do
  for iy=0,w.height-1 do
   func(get_tile(ix,iy))
  end
 end
end

function rnd_tile(func)
 local list={}
 foreach_tile(function(t)
  if (func(t)) add(list,t)
 end)
 
 return rnd_list(list)
end

function create_txt()
 txt={}
 txt.list={}
 txt.show=function(self,src,str,col)
  local t={}
  t.str=str
  t.src=src
  t.col=col
  t.cnt=12
  add(self.list,t)
 end
 
 txt.update=function(self)
  for t in all(self.list) do
    if t.src then
     t.x=t.src.x*8+4
     t.y=t.src.y*8-4
     t.src=nil
    end
   
    t.y-=1
    t.cnt-=1
    if t.cnt==0 then
     del(self.list,t)
    end
  end
 end
 
 txt.draw=function(self)
  for t in all(self.list) do
   if not t.src then
    if (t.col!=0) p_center(t.str,t.x+1,t.y+1,0)
    p_center(t.str,t.x,t.y,t.col)
   end
  end
 end
end
-->8
--player

intro_txt={
 "food",
 "hungry",
 "warm"
}

function create_player(x,y)
 p={}
 p.x=x
 p.y=y
 p.in_den=true
 p.food=13
 p.hp=2
 p.spr=1
 p.flip=false
 p.intro=3
 
 p.move=function(self,dx,dy)
  if self.intro>0 then
   txt:show(self,intro_txt[self.intro],7)
   self.intro-=1
   self.food-=1
   sfx(0)
   return
  end
  
  local x=p.x+dx
  local y=p.y+dy
  

  local t=get_tile(x,y)
  
  -- fix bug if go you of screen
  if not t then
   if not no_hunger then
    self.food-=1
   end
   sfx(0)
   return
  end
  
  local blocked=t.solid
  
  if t.static and
     t.static.hit and
     t.static:hit() then
   blocked=true
  end
  
  if not blocked and 
     t.snow>0 then
   if t.snow==2 then
    --special case: den
    if not t.static or
       not t.static.den then
     if not self.chomp then
      txt:show(p,"stomp",0)
      blocked=true
      self.chomp=true
      sfx(6)
     end
    end
   end
  end
   
  local e=get_mobile(x,y)
  if e then
   if (e.hit) e:hit()
   if (e.solid) blocked=true
  end
 
  self.entered_den=false 
  if not blocked then
   p.x+=dx
   p.y+=dy
   self.in_den=t.static and t.static.den
   self.entered_den=self.in_den
   if self.in_den then
    txt:show(p,"home",7)
   end
   t:clear_snow()
   self.chomp=false
  end
  
  if not no_hunger then
   self.food-=1
  end
  
  sfx(0)
 end
 
 p.eat=function(self,v,what)
  self.food+=v
  txt:show(self,what.." +"..v,7)
  sfx(1)
 end
 
 p.hurt=function(self,v)
  if (no_hurt) return
  self.hp-=v
  if self.hp==1 then
   txt:show(self,"ouch",8)
   self.spr=2
  else
   txt:show(self,"...",8)
   show_scene(ending,4,1)
   self.spr=3
  end
  sfx(2)
 end
 
 p.draw=function(self)
  if self.in_den then
   if w.season=="winter" then
    spr(51,self.x*8,self.y*8)
   else
    spr(35,self.x*8,self.y*8)
   end
  else
   spr(self.spr,self.x*8,self.y*8,1,1,self.flip)
  end
 end
end
-->8
--static

function create_static(x,y,sprite)
 local e={}
 e.x=x
 e.y=y
 e.t=get_tile(x,y)
 e.sprite=sprite
 e.flip=flr(rnd(2))==1
 e.t.static=e
 
 e.remove=function(self)
  self.t.static=nil
 end
 
 e.draw=function(self)
  if self.sprite then
   spr(self.sprite,self.x*8,self.y*8,1,1,self.flip)
  end
 end
 
 return e
end

--------------------------------
-- den
--------------------------------

function open_den()
 local t=rnd_tile(function(t)
  return t.static and
         t.static.den and
         not t.static.opened
 end)
  
 if t then
  t.static.sprite=50
  t.static.opened=true
 end
end

function create_den(x,y)
 local e=create_static(x,y,33)
 e.solid=true
 e.den=true
 e.flip=false
 
 e.open=function(self)
  self.sprite=34
  self.opened=true
 end
 
 e.close=function(self)
  self.sprite=33
  self.opened=false
 end
 
 e.hit=function(self)
  return not self.opened
 end
 
 e.tick=function(self)
  if self.opened then 
   if w.season=="spring" and
      w.turn>6 and
      (p.x!=self.x or p.y!=self.y) then
    self:close()
   end 
  end
 end
 
 --e.freeze=function(self)
 -- self.sprite=50
 -- self.opened=true
 --end
 
 return e
end

--------------------------------
-- tree
--------------------------------

function spawn_cone()
 local t=rnd_tile(function(t)
  return t.static and
         not t.static.frozen and
         t.static.spawn_left and
         t.static.spawn_left>0
 end)
 
 if t then
  t.static:add_cone()
 end
end

function create_tree(x,y)
 local e=create_static(x,y,40)
 e.cone=0
 e.spawn_left=2
 e.solid=true
 e.hp=3
 
 e.hit=function(self)
  if self.cone>0 then
   p:eat(self.cone*4,"cone")
   self.cone=0
  end
  return true
 end
 
 e.freeze=function(self)
  --self.cone=0
  self.sprite=41
 end
 
 e.chop=function(self)
  self.hp-=1
  if self.hp==0 then
   self:remove()
   return true
  end
 end
 
 e.add_cone=function(self)
  if self.cone==2 then
   return false
  end
  
  self.cone+=1
  self.spawn_left-=1
  return true
 end
 
 e.draw=function(self)
  spr(self.sprite,self.x*8,self.y*8,1,1,self.flip)
  if self.cone>0 then
   spr(41+self.cone,self.x*8,self.y*8,1,1,self.flip)
  end 
 end
 
end

--------------------------------
-- flower
--------------------------------

function spawn_flower()
 local t=rnd_tile(function(t)
  return t.basic and
         not t.static and
         not get_mobile(t.x,t.y)
 end)

 if (t) create_flower(t.x,t.y)
end

function create_flower(x,y)
 local e=create_static(x,y,24)
 e.state="stalk"
 e.cnt=5+flr(rnd(5))
 e.food=5
 
 e.hit=function(self)
  local what="flower"
  if (self.state=="stalk") what="stalk"
  p:eat(self.food,what)
  self:remove()
  return false
 end
 
 e.stomp=function(self)
  self:remove()
 end
 
 e.tick=function(self)
  self.cnt-=1
  if self.cnt==0 then
   if self.state=="stalk" then
    self.state="flower"
    self.food=3
    self.cnt=40+flr(rnd(20))
    self.sprite=25
   elseif self.state=="flower" then
    self.state="die"
    --self.food=1
    self.cnt=8+flr(rnd(8))
    self.sprite=26
   else --self.state=="die"
    self:remove()
   end
  end   
 end
 
end

--------------------------------
-- berry
--------------------------------

function spawn_berry()
 local t=rnd_tile(function(t)
  return t.static and
         t.static.berry and
         t.static.berry<3
 end)
 
 if t then
  t.static:add_berry()
 end
end

function wilt_bush()
 local t=rnd_tile(function(t)
  return t.static and 
         t.static.berry and
         not t.static.wilted
 end)
 
 if t then
  t.static:wilt()
 end
end

function create_bush(x,y)
 local e=create_static(x,y,56)
 e.berry=0
 e.berry_cd=0
 e.solid=true
 
 e.hit=function(self)
  if self.berry>0 then
   p:eat(self.berry*4,"berry")
   self.berry=0
   self.berry_cd=4
  end
  return not self.frozen
 end
 
 e.freeze=function(self)
  self.sprite=58
  self.solid=false
 end
 
 e.add_berry=function(self)
  if self.berry==3 or
     self.berry_cd>0 then
   return false
  end
  
  self.berry+=1
  self.berry_cd=4
  return true
 end
 
 e.wilt=function(self)
  self.sprite=57
  self.wilted=true
  self.wilt_cnt=3
 end
 
 e.tick=function(self)
  if (self.berry_cd>0) self.berry_cd-=1
  
  if self.wilted and
     self.berry>0 then
   self.wilt_cnt-=1
   if self.wilt_cnt==0 then
    self.berry-=1
    self.wilt_cnt=2
   end
  end
 end
 
 e.draw=function(self)
  spr(self.sprite,self.x*8,self.y*8,1,1,self.flip)
  if self.berry>0 then
   spr(58+self.berry,self.x*8,self.y*8,1,1,self.flip)
  end 
 end
end

--------------------------------
-- snow
--------------------------------

function spawn_snow()
 local count=10
 if (w.season=="autumn") count=3

 list={}
 foreach_tile(function(t)
  if t.snow_cd>0 then
   t.snow_cd-=1
  elseif not t.water and
         t.snow<2 and
         (t.x!=p.x or t.y!=p.y) then
   add(list,t)
  end
 end)
 
 for i=1,count do
  local t=rnd_list(list)
  if (not t) return
  t:add_snow()
 end
end

function create_snow(x,y)
 local e=create_static(x,y,48)
 e.snow=0
 e.sprite=nil
 
 e.hit=function(self)
  local block=self.snow==4
  
  if self.snow>0 then
   self.snow=0
   self.sprite=nil
  end
  
  if (block) txt:show(p,"stomp",0)
  return block
 end
 
 e.tick=function(self)
  if self.snow<4 then
   self.snow+=1
   self.sprite=47+self.snow
  end
 end
 
 return e
end
-->8
--mobiles

function create_mobile(x,y,spr)
 local e={}
 e.x=x
 e.y=y
 e.spr=spr
 e.flip=flr(rnd(2))==1
 
 e.look_at=function(self,dx,dy)
  if (dx<0) self.flip=false
  if (dx>0) self.flip=true
 end
 
 add(mobiles,e)
 return e
end

function get_mobile(x,y)
 for e in all(mobiles) do
  if e.x==x and e.y==y then
   return e
  end
 end
end

function remove_mobile(e)
 del(mobiles,e)
end

function check_tile(e,dx,dy,list,func)
 local t=get_tile(e.x+dx,e.y+dy)
 if (func(t)) add(list,{x=dx,y=dy,t=t})
end

function rnd_dir(e,func)
 local list={}
 check_tile(e,-1,0,list,func)
 check_tile(e,1,0,list,func)
 check_tile(e,0,-1,list,func)
 check_tile(e,0,1,list,func)
 return rnd_list(list)
end

--------------------------------
-- fish
--------------------------------

function spawn_fish()
 local t=rnd_tile(function(t)
  return t.water and
         not get_mobile(t.x,t.y)
 end)
 

 if (t) create_fish(t.x,t.y)
end

function create_fish(x,y)
 local e=create_mobile(x,y,6)
 e.movecnt=3
 
 e.hit=function(self)
  p:eat(15,"fish")
  remove_mobile(self)
 end
 
 e.tick=function(self)
  if self.movecnt==0 then
   local d=rnd_dir(self,function(t)
    return t.water and
          not get_mobile(t.x,t.y)
   end)
  
   if d then
    self.x+=d.x
    self.y+=d.y
    self.movecnt=3
    self:look_at(d.x,d.y)
   end
  else
   self.movecnt-=1
  end
 end
 
end

--------------------------------
-- base character
--------------------------------

function create_char(x,y,spr)
 local e=create_mobile(x,y,spr)
 e.bspr=e.spr
 
 e.hit=function(self)
  local dx=self.x-p.x
  local dy=self.y-p.y
  
  --special: house
  local t=get_tile(self.x+dx,self.y+dy)
  if t.house then 
   remove_mobile(self)
   txt:show(t,"home",7)
   sfx(1)
  elseif not self:move(dx,dy) then
   remove_mobile(self)
   txt:show(p,"crunch",8)
   sfx(5)
  end
 end
 
 e.move=function(self,dx,dy)
  local t=get_tile(self.x+dx,self.y+dy)
  
  if (t:is_solid()) return false
  self.x=t.x
  self.y=t.y
  self:look_at(dx,dy)
  if (t.static and t.static.stomp) t.static:stomp()
  return true
 end
 
 e.wander=function(self)
  local d=rnd_dir(self,function(t)
   return not t:is_solid()
  end)
 
  if (d) self:move(d.x,d.y)
  self.spr=self.bspr
 end
 
 
 e.check_flee=function(self)
  local flee=false
  if p.x==self.x then
   flee=abs(p.y-self.y)==1
  elseif p.y==self.y then
   flee=abs(p.x-self.x)==1
  end
  
  if flee and not self.flee then
   self.flee=true
   self.spr=self.bspr+1
   txt:show(self,"help!",7)
   if (self.on_flee) self:on_flee()
  elseif not flee and self.flee then
   self.flee=false
   self.spr=self.bspr
   --special case: skip one
   --move after stop flee
   return true
  end 
  return self.flee
 end
 
 e.tick=function(self)
  if not self:check_flee() then
   self:update()
   self:check_flee()
  end
  
 end
 
 return e
end

--------------------------------
-- jack
--------------------------------

function spawn_jack()
 local t=rnd_tile(function(t)
  return t.house and         
         not get_mobile(t.x,t.y)
 end)

 if (t) create_jack(t.x,t.y)
end

function create_jack(x,y)
 local e=create_char(x,y,8)
 
 e.on_flee=function(self)
  self.chop_target=nil
 end
 
 e.update=function(self)
  if self.chop_target and
     self.chop_target.hp==0 then
   self.chop_target=nil
  end
  
  if not self.chop_target then
   -- find chop target
   local d=rnd_dir(self,function(t)
   	if (p.x==t.x and p.y==t.y) return false
   	return t.static and t.static.chop
  	end)
  
  	if d then
  	 -- chop target found
  	 self.chop_target=d.t.static
    self:look_at(d.x,d.y)
    self.chop_cnt=2
   end
  end
  
  if self.chop_target then
   -- state: chop
   self.chop_cnt-=1
   if self.chop_cnt==0 then
    self.chop_target:chop()
    self.chop_cnt=2
    txt:show(self.chop_target,"chop",8)
    self.spr=self.bspr
   else
    self.spr=self.bspr+2
   end
  else
   -- state: wander
   self:wander()
  end
 end
 
end

--------------------------------
-- hunter
--------------------------------

function spawn_hunter()
 local t=rnd_tile(function(t)
  return t.house and         
         not get_mobile(t.x,t.y)
 end)
 
 if (t) create_hunter(t.x,t.y)
end

function create_hunter(x,y)
 local e=create_char(x,y,12)
 e.shoot_cd=2
 
 e.on_flee=function(self)
  self.shoot_cd=0
 end
 
 e.update=function(self)
  if (self.shoot_cd>0) self.shoot_cd-=1
  
  if self.shoot_cd==0 and self:shoot() then
   self.shoot_cd=2
   self.spr=self.bspr+2   
  else
   self:wander()
  end
 end
 
 e.try_shoot=function(self,dx,dy)
  local x=self.x+dx
  local y=self.y+dy
  for i=0,16 do
   local t=get_tile(x,y)
   
   if p.x==x and p.y==y then
    if (i<1) return false
    p:hurt(1)
    self:look_at(dx,dy)
    c:shake(dx*10,dy*10)
    return true
   end
   
   if (not t.water and t:is_solid()) return false
   
   x+=dx
   y+=dy
  end
  return false
 end
 
 e.shoot=function(self)
  if (self:try_shoot(-1,0)) return true
  if (self:try_shoot(1,0)) return true
  if (self:try_shoot(0,-1)) return true
  if (self:try_shoot(0,1)) return true
  return false
 end
 
end
-->8
--title

title={}

title.init=function(self)
 self.titlecnt=10
 self.beary=28
 self.bearfade=16
 self.started=false
end

title.update=function(self)
 if not is_fading() and
    (btnp(0) or
     btnp(1) or
     btnp(2) or
     btnp(3)) then
  show_scene(game,2,8)
  sfx(5)
 end
end

title.draw=function(self)
 cls()
 
 if (not is_fading()) fade(0)
 
 --title
 spr(128,0,55,16,3)
 
 if self.titlecnt>0 then
  if (not is_fading()) self.titlecnt-=1
 else 
  if (not is_fading()) fade(self.bearfade)
  if self.bearfade>0 then
   self.bearfade-=1
   if (self.bearfade==8) sfx(2)
  end
 
  spr(68,48,self.beary,4,4)
  
  --left claw
  spr(64,26,self.beary+15,2,2)
  
  --right claw
  spr(66,86,self.beary+15,2,2)
  
  if self.beary<30 then
    self.beary+=0.25
  end
   
  if(self.bearfade==0) then
    if blink() then
     if (not is_fading()) p_center("press any arrow",64,96,7)
    end
    color(6)
    print("v1.0",112,122)
    print("(c)2019 insert disk 2",1,122)
    
   --end
  end
 end
end

-->8
--ending

ending={}

ending.init=function(self)
 self.txt={}
 
 if p.hp==0 then
  add(self.txt,"you got deadly wounded.")
  add(self.txt,"try again.")
 elseif p.food==0 then
  add(self.txt,"you died out of starvation.")
  add(self.txt,"try again.")
 elseif p.food<12 then
  add(self.txt,"you survived until winter.")
  add(self.txt,"but you where not strong enough.")
  add(self.txt,"you died in your sleep.")
  self.finished=true 
 elseif p.food<26 then
  add(self.txt,"you survived this winter.")
  add(self.txt,"but you woke up weakened.")
  add(self.txt,"you died next spring.")
  self.finished=true
 else
  add(self.txt,"you survived this winter.")
  add(self.txt,"and the next one.")
  add(self.txt,"and many others.")
  add(self.txt,"you lived an happy bear life.")
  self.finished=true
 end
 
 self.txt_y=56-#self.txt*3
end

ending.update=function(self)
 if not is_fading() and
    (btnp(0) or
     btnp(1) or
     btnp(2) or
     btnp(3)) then
  if self.finished then
   show_scene(title,1,1)
  else
   show_scene(game,1,1)
  end
  sfx(5)
 end
end

ending.draw=function(self)
 cls()
 color(7)
 for i=1,#self.txt do
  p_center(self.txt[i],64,self.txt_y+i*6)
 end
 
 if p.food>0 and p.hp>0 then
  p_center("score: "..p.food,64,108)
 end
end

-->8
--proc-gen
mwidth=16
mheight=15

cfg={
 den_count=4,
 house_count=3,
 bush_space=6,
 bush_rnd=3,
 tree_space=9,
 tree_rnd=5,
 rock_count=4,
 stalk_count=3,
 ground_alt1_count=20,
 ground_alt2_count=8
}

function gen_map()
 while true do
  if (try_gen_map()) return
 end
end

function try_gen_map()

 --grass
 g_foreach(function(t)
  mset(t.x,t.y,16)
 end)
 
 --mountains
 local ids={0,1,2,3}
 g_mountain(ids,0,0,false,false)
 g_mountain(ids,8,0,true,false)
 g_mountain(ids,0,7,false,true)
 g_mountain(ids,8,7,true,true)
 
 --dens
 local dens=g_keep(34,33,cfg.den_count)
 
 --houses
 g_keep(32,16,cfg.house_count)
 
 --lakes
 ids={0,1,2,3}
 if flr(rnd(2))==0 then
  g_lake(ids,4,4,-1,-1)
  g_lake(ids,8,8,1,1)
 else
  g_lake(ids,4,8,-1,1)
  g_lake(ids,8,4,1,-1)
 end

 --bushes and trees
 if (not g_place_space(56,cfg.bush_space)) return false
 if (not g_place_space(40,cfg.tree_space)) return false
 
 if (not g_place_rnd(56,cfg.bush_rnd)) return false
 if (not g_place_rnd(40,cfg.tree_rnd)) return false
 
 --rocks
 g_place_rnd(33,cfg.rock_count)
 
 --player
 local start=rnd_list(dens)
 mset(start.x,start.y,1)

 --check paths 
 if (not f_check(start)) return false
 
 --initial stalks
 if not g_place_rnd(24,
               cfg.stalk_count,
               start.x-3,
               start.y-3,
               7,7) then
  return false
 end
  
 --ground alt
 g_place_rnd(19, cfg.ground_alt1_count)
 g_place_rnd(18, cfg.ground_alt2_count)
 
 return true
end

function g_mountain(ids,x,y,fliph,flipv)
 local id=rnd_list(ids)
 g_render(x,y,8,8,16+id*8,0,fliph,flipv)
end

function g_lake(ids,x,y,offset_x,offset_y)
 local id=rnd_list(ids)
 local tmp=flr(rnd(3))
 
 if tmp==0 then
  x+=offset_x
 elseif tmp==1 then
  y+=offset_y
 end
  
 g_render(x,y,4,3,112+id*4,0)
end

function g_render(x,y,w,h,sx,sy,fliph,flipv)
 for ix=0,w-1 do
  for iy=0,h-1 do
   local msx=sx+ix
   if (fliph) msx=sx+(w-ix-1)
   
   local msy=sy+iy
   if (flipv) msy=sy+(h-iy-1)
   local tid=mget(msx,msy)
   if (tid>0) mset(x+ix,y+iy,tid)
  end
 end
end

function g_foreach(func)
 for ix=0,mwidth-1 do
  for iy=0,mheight-1 do
   func({x=ix,y=iy,id=mget(ix,iy)})
  end
 end
end

function g_select(tid,x,y,w,h)
 x=x or 0
 y=y or 0
 w=w or mwidth
 h=h or mheight
 
 list={}
 for ix=x,x+w-1 do
  for iy=y,y+h-1 do
   local id=g_mget(ix,iy)
   if id==tid then
    add(list,{x=ix,y=iy,id=id})
   end
  end
 end
 
 return list
end

function g_mget(x,y)
 if x<0 or y<0 or
    x>=mwidth or y>=mheight then
  return 33
 end
 
 return mget(x,y)
end

function g_keep(src_tid,dst_tid,count)
 local list=g_select(src_tid)
 while #list>count do
  local t=rnd_list(list)
  mset(t.x,t.y,dst_tid)
 end
 return list
end

function g_place_rnd(tid,count,x,y,w,h)
 local list=g_select(16,x,y,w,h)
 for i=1,count do
  local t=rnd_list(list)
  if (not t) return false
  mset(t.x,t.y,tid)
 end
 return true
end

function g_place_space(tid,count,x,y,w,h)
 local list=g_select(16,x,y,w,h)
 while count>0 do
  local t=rnd_list(list)
  if (not t) return false
  if g_check_space(t.x,t.y) then 
   mset(t.x,t.y,tid)
   count-=1
  end
 end
 return count==0
end

function g_check_space(x,y)
 for ix=-1,1 do
  for iy=-1,1 do
   local tid=mget(x+ix,y+iy)
   if tid!=16 and tid!=33 then
    return false
   end
  end
 end
 return true
end

--------------------------------
--flood fill
--------------------------------

function f_init()
 f_map={}
 
 for ix=0,mwidth-1 do
  f_map[ix]={}
  for iy=0,mheight-1 do
   local t={
    x=ix,
    y=iy,
   }
   local tid=mget(ix,iy)
   t.need=tid==16 or
          tid==32 or
          tid==34
   t.empty=tid==16
   f_map[ix][iy]=t
  end
 end
end

function f_check(start)
 --local start=f_map[x][y]
 --if (not start.empty) return false
 
 f_init()
 
 --for ix=0,mwidth-1 do
 -- for iy=0,mheight-1 do
 --  f_map[ix][iy].visited=false
 -- end
 --end
 
 local list={}
 add(list,start)

 while #list>0 do
  local t=list[1]
  del(list,t)
  
  if (t==start or t.empty) and
     not t.visited then
   if (t.x>0) f_check_v(list,t.x-1,t.y)
   if (t.x<mwidth-1) f_check_v(list,t.x+1,t.y)
   if (t.y>0) f_check_v(list,t.x,t.y-1)
   if (t.y<mheight-1) f_check_v(list,t.x,t.y+1)
  end
  t.visited=true
 end
 
 for ix=0,mwidth-1 do
  for iy=0,mheight-1 do
   local t=f_map[ix][iy]
   if t.need and
      not t.visited then
    --cls()
    --stop("fail at "..ix..","..iy.." tid="..mget(ix,iy))
    return false
   end
  end
 end
 
 return true
end

function f_check_v(list,x,y)
 local t=f_map[x][y]
 if not t.visited then
  add(list,t)
 end
end

function f_find()
 local list=g_select(16)
 
 while #list>0 do
  local t=rnd_list(list)
  if f_check(t.x,t.y) then
   return t
  end
 end
 
 return nil
end

function f_place(tid,count)
 for i=1,count do
  local t=f_find()
  if (not t) return false
  f_map[t.x][t.y].empty=false
  mset(t.x,t.y,tid)
 end
 
 return true
end
__gfx__
eeeeeeeeee4eeeeeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee111eeee9111eeeee111eeeeeeeeeeeee444eeee9444eeeee444eeeeeeeeee
eeeeeeeee4544eeee8541eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1111eeee1111e9ee1111eeeeeeeeeeee44444eee44449eee44444eeeeeeeee
ee7ee7ee4944444e4948554eeeeeeeeeeeeeeeeeeeeeeeeeeddddeddeeeeeeeeeee9948eee899488eee9948eeeeeeeeeeee9943eee39943eeee9943eeeeeeeee
eee77eee4444444444444444eeeeeeeeeeeeeeeeeeeeeeeedaddddddeeeeeeeeeee4488eeee4488874e44888eeeeeeeeeee993b4eee993b4eee993b4eeeeeeee
eee77eeeee444444ee448448ee4eeeeeeeeeeeeeeeeeeeeedddddddeeeeeeeeeee988888eee8888e77488898eeeeeeeeee9332b4eee332b4eee332b4eeeeeeee
ee7ee7eeee544444ee544441e444445eeeeeeeeeeeeeeeeeeddddeddeeeeeeeeeee88898eee8888eee98888eeeeeeeeeeee3393eeee3332e19119b3eeeeeeeee
eeeeeeeeee445454ee44545441454445eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee2ee2eeee2ee2eeee2ee2eeeeeeeeeeee2222eeee2222eeee2222eeeeeeeee
eeeeeeeee44e45e5e44e45e545544544eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44e44eee44e44eee44e44eeeeeeeeeee44e44eee44e44eee44e44eeeeeeeee
bbbbbbbbb7bbbbb7bbbbbbbbbbbbbbbbb9bb9db9db99d99bbd99bdbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbbbb777bbbbbbbbbbbdbbbbbb9dcddcf6cccdccfdcccddcfbeeeeeeeeeeeeeeeeeeee7eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbb7b777b7bbbbbbbbbbbbbbbbddccc66cccccc66cccccc66cceeeeeeeeeeeeeeeeeee787eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbb6b677b7bbbddbbbbbbbbbbb9ccccccccccccccccccccccceeeeeeeeeeeeaeeeeeee7eeeeeee6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbbbbbbbbbbbdbbdbbbbbdbbbbdccccccfcccccccfcccccccfeeeeeeeeee3e3eeeee3e3eeeeee646eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbbb6bb7bbbbbbbbbbbbbbbbbb96ccccccc6ccccccc6cccccceeeeeeeeeee3eeeeeee3eeeeeee26eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbb77bb6b77bbbbbbbbbbbbbbbb9ccccccccccccccccccccccceeeeeeeeee434e4eee232eeeee2422eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbb77bb77bbbbbbbbbbbbbbbbbbcccc6ccccccc6ccccccc6cbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee94e2eee1111eeeed6d5eeeed6d5eebccccccccccccccccccccccbeeeeeeeeeeee2eeeeeee2eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee95542eedd6d55eed65d55eed65d55edcccccf6ccccccf6ccccccf6eeeeeeeeeee23eeeeee23eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e954454ed666d555ed5d555eed5d555e9ccc66cccccc66cccccc66cceeeeeeeeee2b32eeee2772eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
95444454666ddd55d5000055d5000055ddcccccccccccccccccccccceeeeeeeeee23b31eee27b71ee641eeeee641eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e464444e666ddd55d0000005d0040405bccccccfcccccccfcccccccfeeeeeeeee33b32eee37b32eee441eeeee441e641eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e444444e66ddddd55000111550444445b6ccccccc6ccccccc6cccccceeeeeeeee2b3b31ee2b3b31ee11eeeeee11ee441eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e441144e66ddddd5d0011115d09494159ccccccccccccccccccccccceeeeeeee2334323123343231eeeeeeeeeeeee111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e441144e6dddddd55000000550444045dcccc6ccccccc6ccccccc6cbeeeeeeeeeee41eeeeee41eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee94e2eee1111eeeed6d5eeeed6d5eebccccccccccccccccccccccbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee97742eed7776deed65d55eed65d55e9cccccf6ccccccf6ccccccf6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e974474ed777676ded76775eed76775e9ccc66cccccc66cccccc66cceeeeeeeeee2332eeee1441eeeeeeeeeeeeeeeeeeeeeeeeeeeeee7c1eeeeeeeeeeeeeeeee
9744447466767756d7000065d70000659ccccccccccccccccccccccceeeeeeeee3bbb33ee493944eee4eeeeee7c1eeeee7c1eeeeeee1cc1eeeeeeeeeeeeeeeee
e444444e67676655d0000005d0040405dccccccfcccccccfcccccccfeeeeeeee2bbbbdb219393d31ee4e4e2eecc1eeeeecc17c1ee7c111eeeeeeeeeeeeeeeeee
e447744e766d6765500011175044444796ccccccc6ccccccc6cccccceeeeeeee3bdbdbd343d3d334eee4e2eee11eeeeee11ecc1eecc17c1eeeeeeeeeeeeeeeee
e441144e66d6d6d5d0011115d0949415bccccccccccccccccccccccbeeeeeeee23bdbd32143d3341eeee1eeeeeeeeeeeeeee11eee11ecc1eeeeeeeeeeeeeeeee
e441144e6d66ddd55000000550444045bbdcc6cbbcccc6cbbcccc6bbeeeeeeeee233b32ee144341eeeeeeeeeeeeeeeeeeeeeeeeeeeee11eeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebdc6cd6cdcc6c6cdd6c6dcdbbdc6dcdb
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed6766c66c7676c667c7c676dd676676d
eeeeeee2442eeeeeeeeee2442eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeecc67777776677777c6677776cc677776
eeee244444442eeeeee244444442eeeeeeee44eeeeee4444444eeeeeee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66767777677677776776776766767777
ee244444444442eeee244444444442eeeee44444ee444444444444ee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed77777777777777777777776c6677776
e2444444444444eeee4444444444442eeee50444444444444444444444405eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeec67776cc777776cc7777766cdc6776cc
e44444244424442ee24442444244444eeee55044444444444444444444055eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee677667766776677667766776d6c6c7cd
244244454445444ee444544454442442eeee504444444444444444444405eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed677776cc677776cc67776c6bd7c7cdb
24454445444544422444544454445442eeeee4444444444444444444404eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed6c6776776c6776776c6776cd6c6776c
02d45444544454444445444544454d20eeeee4440000404440400004444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedc776c6677776c6677776c66dc776c66
e0dde4d404d4e4d44d404d404d40dd0eeeee44444009040004090044444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeec66777777667777776677767c6677767
ee0de0dde0dde0dddd0edd0edd0ed0eeeeee444444404000004044444554eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6c76777767767777677676c66c7676c6
eee0ee0dee0dee0dd0eed0eed0ee0eeeeee4444444040000000404445554eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed6777777777777777777777cd677777c
eeeeeee0eee0eee00eee0eee0eeeeeeeeee4544444040050500404455554eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeec77776cc777776cc777776ccc77776cc
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee445544440440555044045555544eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6c76677667766776677667766c766776
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee445544440445555544045555444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeec677776cc677776cc677776cc677776c
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4455554404d06060d4045555444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6cc6776776c6776776c67767dcc6c6cd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444555440060d0d060045555444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedc776c6677776c6677776c66c7676c66
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4445554400d00000d0044554044eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeec6677777766777777667777676677777
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee440555544000000000444554044eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6c767777677677776776776767767777
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee040455544000000000445554040eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeec6677777777777777777777677777777
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee044055544400000000445540440eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedc6776cc777776cc777776cc777776cc
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0404555440000000444554040eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed6c66776677667766776c7cd67766776
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee040455440022200445540440eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd7c776cc677776cc67c7cdbc677c76c
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0404554522222544540440eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebdc6cd6cd6c6dcdbbdc6dcdbd6c6776c
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee04045462525264450400eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed6766c667c7c676dd676676ddc776c66
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0e0545060605440e0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeecc677777c6677776cc677776c6677767
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00444444400eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6676777767767777667676c66c7676c6
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeec667777777777776d677777cd677777c
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedc6776cc777776ccc77776ccdc67767c
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed6c667766776c7cd6c766776d6c6c7cd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd7c776cc67c7cdbc677776cbd7c7cdb
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee777aaaaaaaaeeeeee777aaaaaaaaaaeeeeeee777aaaeeeeeeee777aaaaaaaaeeeeee777aaaaaaaaeeeeee777aaaeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee77444444444aeeeee774444444444aeeeeeee77444aeeeeeeee77444444444aaeeee77444444444aaeeee77444aeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee724444444444aeeee744444444444aeeeeeee744444aeeeeeee7444444444444aeee7444444444444aeee74444aeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeea444444444444aeeea44444444444aeeeeeeea44444aeeeeeeea444444444444aeeea444444444444aeeea4444aeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeea4444aaaa44444aeea4444aaaaaaaaeeeeeea4444444aeeeeeea4444aaaaa4444aeea4444aaaaa4444aeea4444aeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeea4444aeeea4444aeea4444aeeeeeeeeeeeeea444a444aeeeeeea4444aeeeea444aeea4444aeeeea444aeea4444aeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeea4444aeeea4444aeea4444aeeeeeeeeeeeeea444a444aeeeeeea4444aeeeea444aeea4444aeeeea444aeea4444aeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeea4444aeeea444aeeea4444aeeeeeeeeeeeea444aa4444aeeeeea4444aeeeea444aeea4444aeeeea444aeea4444aeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeea4444aaaa4444aeeea4444aaaaaaaeeeeeea444aea444aeeeeea4444aeeea4444aeea4444aeeea4444aeea4444aeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeea44444444444aeeeea4444444444aeeeeea4444aea444aeeeeea4444aaaa4444aeeea4444aaaa4444aeeea4444aeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeea44444444444aeeeea4444444444aeeeeea444aeeaa444aeeeea444444444444aeeea444444444444aeeea4444aeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee94444444444449eee944444444449eeeee94449eee94449eeee9444444444499eeee9444444444499eeee944449eeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee944449999944449ee944449999999eeee94444999994449eeee944444444449eeeee944444444449eeeee944449eeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee944449eeee94449ee944449eeeeeeeeee944444444444449eee9444499944449eeee9444499944449eeee944449eeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee944449eeee944449e944449eeeeeeeeee944444444444449eee944449ee944449eee944449ee944449eee944449eeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee944449eeee944449e944449eeeeeeeee94444444444444449ee944449eee94449eee944449eee94449eee944449eeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee944449eeee944449e944449eeeeeeeee94449999999944449ee944449eee944449ee944449eee944449ee944449eeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee944449999944449ee9444499999999ee94449eeeeeee94449ee944449eeee94449ee944449eeee94449ee9444499999999eeeeeeeeeeeeee
eeeeeeeeeeeeeeee944444444444449ee9444444444449e944449eeeeeee944449e944449eeee944449e944449eeee944449e9444444444449eeeeeeeeeeeeee
eeeeeeeeeeeeeeee92444444444229eee9244444444429e92429eeeeeeee924429e924429eeeee924429924429eeeee9244299244444444429eeeeeeeeeeeeee
eeeeeeeeeeeeeeee9222222222299eeee9222222222229922229eeeeeeeee92229e922229eeeee922229922229eeeee9222299222222222229eeeeeeeeeeeeee
eeeeeeeeeeeeeeee99999999999eeeeee9999999999999999999eeeeeeeee99999e999999eeeee999999999999eeeee9999999999999999999eeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bd88888888888888888888dbbd8888dbeeeeeeeebbbbbbbb000000000000000000000800bb1111bbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d8766c66c7676c667c7c678dd876678deeeeeeeebbbf1bbb000800000000080000000000bd7776dbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
8c67777776677777c66777788c677778eeeeeeeebbb113bb000090000000900000800000d777676deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
86767777677677776776777886767778eeeeeeeebf1bb3bb0000a9000090a8000000900066767756eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
87777777777777777777777886677778eeeeeeeeb11bbf1b0008aa0000097a000000a90067676655eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
867776cc777776cc777776c88c6776c8eeeeeeeebbb3b11b009a7a80008a7a800009aa00766d6765eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
877667766776677667766778d8c6c78deeeeeeeebbb3bb3300877a900089a900008aaa8066d6d6d5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
8677776cc677776cc6777768bd8888dbeeeeeeeebbbbbb3b0007a900000898000089a9806d66ddd5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
86c6776776c6776776c6776886c67768eeeeeeee00008000000dd000eeeeeeeeeeeeeeee157761d1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
8c776c6677776c6677776c688c776c68eeeeeeee0000800000d25d00eeeeeeeeeeeeeeee5776cd1deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
86677777766777777667777886677778eeeeeeee000000000d2555d0eeeeeeeeeeeeeeeecc676c11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
8c76777767767777677677788c767778eeeeeeee988000880255555deeeeeeeeeeeeeeeed676d651eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
86777777777777777777777886777778eeeeeeee0000000005555550eeeeeeeeeeeeeeeec77671d5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
877776cc777776cc777776c8877776c8eeeeeeee0000800005511550eeeeeeeeeeeeeeee67c76d11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
8c76677667766776677667788c766778eeeeeeee0000800005512550eeeeeeeeeeeeeeee6cc6dcd1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
8677776cc677776cc677776886777768eeeeeeee0000000005512550eeeeeeeeeeeeeeeeccdccdddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
8cc6776776c6776776c6776888888888eeeeeeee00233200001132000023320000231100eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
8c776c6677776c6677776c68c7676c66eeeeeeee03bbb33001781330011bb33003b17810eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
86677777766777777667777876677777eeeeeeee2bbbbbb221881bb21781bbb221118812eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
8c767777677677776776776867767777eeeeeeee3bdbdbd33b11dbd31881d11317811113eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
86677777777777777777777877777777eeeeeeee23bdbd3223bdbd32211d178118811781eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
8c6776cc777776cc777776c8777776cceeeeeeee02544220025442200254188103141881eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d8c66776677667766776c78d67766776eeeeeeee00042100000421000004211000042100eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bd88888888888888888888db88888888eeeeeeee00242210002422100024221000242210eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
76888888888888677688886786c67768eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
78776c6677776c8678776c8687776c68eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
86677777766777788667777886677778eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
87767777677677788776777887767778eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
87777777777777788777777887777778eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
877776cc777776c8877776c8877776c8eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
68766776677667868776677868766786eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
c68888888888886c86777768c688886ceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000004400000044444440000000440000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000044444004444444444440044444000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000050444444444444444444444405000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000055044444444444444444444055000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000005044444444444444444444050000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000444444444444444444440400000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000444000040444040000444400000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000004444400904000409004444400000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000004444444040000040444445540000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000044444440400000004044455540000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000045444440400505004044555540000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000445544440440555044045555544000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000445544440445555544045555444000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000004455554404d06060d4045555444000000000000000000000000000000000000000000000000000
00000000000000000000000000000000024420000000000000444555440060d0d060045555444000000000000002442000000000000000000000000000000000
000000000000000000000000000000244444442000000000004445554400d00000d0044554044000000000000244444442000000000000000000000000000000
00000000000000000000000000002444444444420000000000440555544000000000444554044000000000002444444444420000000000000000000000000000
00000000000000000000000000024444444444440000000000040455544000000000445554040000000000004444444444442000000000000000000000000000
00000000000000000000000000044444244424442000000000044055544400000000445540440000000000024442444244444000000000000000000000000000
00000000000000000000000000244244454445444000000000004045554400000004445540400000000000044454445444244200000000000000000000000000
00000000000000000000000000244544454445444200000000000404554400222004455404400000000000244454445444544200000000000000000000000000
0000000000000000000000000002d4544454445444000000000000404554522222544540440000000000004445444544454d2000000000000000000000000000
0000000000000000000000000000dd04d404d404d4000000000000040454625252644504000000000000004d404d404d40dd0000000000000000000000000000
0000000000000000777aaaaaaaa00d00dd70dda0ddaaaa0000000770a0545060605440a0aaaaaa00000077dd0add0add00d00777aaa0f0f0f0f0000000000000
000000000000000077444444444af0000d740d440d444a00000007744400444444400444444444aa000077d044d044d0a000077444a000000000000000000000
0000000000000000724444444444a0000044404440444a0000000744444a00f0f007444444444444a0007404440444044a00074444a000000000000000000000
0000000000000000a444444444444a000a44444444444a0000000a44444a0000000a444444444444a000a444444444444a000a4444a000000000000000000000
0000000000000000a4444aaaa44444a00a4444aaaaaaaa000000a4444444a000000a4444aaaaa4444a00a4444aaaaa4444a00a4444a000000000000000000000
0000000000000000a4444a000a4444a00a4444a0000000000000a444a444a000000a4444a0000a444a00a4444a0000a444a00a4444a000000000000000000000
0000000000000000a4444a000a4444a00a4444a0000000000000a444a444a000000a4444a0000a444a00a4444a0000a444a00a4444a000000000000000000000
0000000000000000a4444a000a444a000a4444a000000000000a444aa4444a00000a4444a0000a444a00a4444a0000a444a00a4444a000000000000000000000
0000000000000000a4444aaaa4444a000a4444aaaaaaa000000a444a0a444a00000a4444a000a4444a00a4444a000a4444a00a4444a000000000000000000000
0000000000000000a44444444444a0000a4444444444a00000a4444a0a444a00000a4444aaaa4444a000a4444aaaa4444a000a4444a000000000000000000000
0000000000000000a44444444444a0000a4444444444a00000a444a00aa444a0000a444444444444a000a444444444444a000a4444a000000000000000000000
00000000000000009444444444444900094444444444900000944490009444900009444444444499000094444444444990000944449000000000000000000000
00000000000000009444499999444490094444999999900009444499999444900009444444444490000094444444444900000944449000000000000000000000
00000000000000009444490000944490094444900000000009444444444444490009444499944449000094444999444490000944449000000000000000000000
00000000000000009444490000944449094444900000000009444444444444490009444490094444900094444900944449000944449000000000000000000000
00000000000000009444490000944449094444900000000094444444444444449009444490009444900094444900094449000944449000000000000000000000
00000000000000009444490000944449094444900000000094449999999944449009444490009444490094444900094444900944449000000000000000000000
00000000000000009444499999444490094444999999990094449000000094449009444490000944490094444900009444900944449999999900000000000000
00000000000000009444444444444490094444444444490944449000000094444909444490000944449094444900009444490944444444444900000000000000
00000000000000009244444444422900092444444444290924290000000092442909244290000092442992442900000924429924444444442900000000000000
00000000000000009222222222299000092222222222299222290000000009222909222290000092222992222900000922229922222222222900000000000000
00000000000000009999999999900000099999999999999999990000000009999909999990000099999999999900000999999999999999999900000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000f00000000000000f000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000f00000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000f000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000f000000000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00000000000000000000000000000000000000
00000000000000000000000000f00000000000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000000
0000000000f0000000000000000000000000000000000000000000000000000000000000f0000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000f0000000000000000000000000000000000000000000f000000000000000000000000
000000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000f000000000000000000000000000000000000000000000000000000000f0000000000000000000000000000000f000000000000000000000
0000000000000000000000000000000000f0000000000000000000000000f00000f000000000000000000000000000f000000000000000000000000000000000
000000000000000000000000000000000077707770777007700770000077707700707000007770777077700770707000000000000000000f00f0f000f0000000
000000000000000000000000000000000070707070700070007000000070707070707000007070707070707070707000000000f0000000000000f00000000000
0000000000000000000000000000000000777077007700777077700000777070707770000077707700770070707070000000000000000000000000f0000f0000
0000000000000000000000000000000000700070707000007000700000707070700f70f0007070707070707070777000000000000f0000000000000000000000
00000000000000000000000f0f0f0f0f0070007070777077f077000000707070707770000070707070707077007770000000000000000000000000f000000000
000000000f000000000f00000000000000000f000000f0000000000000000000000000000000000000000000000000000000000000f000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000f00000000000f000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000f000000000000000000000000000000000000000000000000000f0000000000000000000000000000000000000
0000f000f00000000000000000000000000000000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000000000000000f00
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000000000000000000000000000000
000000000000000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000f0000000000000000000000000000000000000000000000000000000000000000000000000000f00000000000000000000000f0f000000000
0f000000000000000000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000f0000000000000000000000000000000000000000000000000000000f000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000f0000000000000f000f0f0f00000000000000000f00000000000000f0000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000f000000000000000000000000000000000000000000000000000f0f0000000000000000000000000f0000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000f0000000000000000000000000000000000000000f000000000000000000000
0000000000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0060006600600666066606600666000006660660006606660666066600000660066600660606000f06660f0000000000000000f0000000006060660000006660
0600060000f60006060600600606f000006006060600060006060060000006060060060006060000f006000000000000000000000000000060600600ff006060
06000600000606660606006006660000006006060666066006600060000006060060066606600000066600000000000000000000000000006060060000006060
f600060000f606f0f6f6f06000f600f000600606000606000606006000000606006000060606000006000000000000000f000000000000006660060000006060
0060006600600666066606660006000006660606066006660606006000000666066606600606000006660000000000000f00000000f000000600666006006660
000000000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000001000000000000000008000000030303010000000000000000010100000302030000000000000000000000000003030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2121212121212121212121212121212121212121212122212121212121212121212121212121212121212121222121210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000141600000014161415160000141600
2121212113131313382121202113212121212120210000002121212200002000212121212200200021212121002120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000242600001425263435251614253500
2121281310141610101328131312212121210000000000002121210000000000212120000000000021212200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000343600003435360000343634260000
2120131012342515161010101038132122000000000000002121000000000000210000000000000021210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2113103810103435361012281010132121000000000000002100000000000000220000000000000021200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2113101028101010101010103810132221200000000000002100000000000000212100000000000021210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2128101010102810103810101010132121000000000000002120000000000000212100000000000021210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2213281038101012101010141613212121000000000000002100000000000000210000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2113101210101010101814253610132200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2128101028101010101034361013212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121381010101321131010181021132100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121132810381013181028103813212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121211310101028132113101321212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212120211313212121012121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000000001415016150181501915019150181501515013140121300f1300e1300c1200a12009120071200612005120051200411003110021100210002100011000110001100011000400001100010000100001000
00010000050500705008050080500a0500b0500d0500d0500e0500d0500e0500f05010050110501205015050170501a0501c0501f050210502305026050280502b05030050330503b0503f0303f0203f0203f010
000100003c25039250362503425031250302502d2502a250252501f2501b25019250172501225011250112500f2500e2500d2500d2500e2500d2500d250092500625004250042500325003250032500000000000
000000003f0203c030360503505034050300502f0502b0502a040280402604023040220301f0301d020180201402013010110100f0100d0100a00007000030000100001000030000300003000030000200002000
001c00001e1501e150201502315023150201501e1501b1501d150171501915013150151500d150121500b15011150081500f1500e1501515011150191501d150231501c100191001510000000151001d1001d100
000100000615006150071500715008150091500a1500a1500b1500d1500f1501115012150131501615017150191501a1501e1502215024150271502a1502d150301503415036150391503c1503f1503f15039150
00000000000001e6501c6501b6501a6501a65017650166501565015650146501365011650106500e6400c6400a630086300762006620056100261001610016100160001600026000160001600000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000

