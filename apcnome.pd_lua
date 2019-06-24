local apcGrid ={{56,57,58,59,60,61,62,63},
                {48,49,50,51,52,53,54,55},
                {40,41,42,43,44,45,46,47},
                {32,33,34,35,36,37,38,39},
                {24,25,26,27,28,29,30,31},
                {16,17,18,19,20,21,22,23},
                {8,9,10,11,12,13,14,15},
                {0,1,2,3,4,5,6,7}
              }

local function toBits(num)
  -- returns a table of bits, least significant first.
  local t={} -- will contain the bits
  while num>0 do
    rest=math.fmod(num,2)
    t[#t+1]=rest
    num=(num-rest)/2
  end
  return t
end


local function notecoord(note,vel)
  local x = (note%8)
  local y = 7 - math.floor(note/8)
  return x,y,vel
end

local function brightness(val)
  --corresponds here to the 4 available states on apc: 0(off), 1(green) , 3(yellow), 5(red)
  if val < 4 then
    return 0
  elseif (val > 3) and (val < 8) then
    return 1
  elseif (val > 7) and (val < 12) then
    return 3
  elseif (val > 11) and (val < 16) then
    return 5
  else
    return 0
  end
end


local apcnome = pd.Class:new():register("apcnome")

function apcnome:initialize(name, atoms)
  self.outlets = 2
  self.inlets = 2
  return true
end

function apcnome:in_1(sel,list)

  if sel == "/monome/grid/led/set" then --f f f (x y value)
    self:outlet(1,"float",{144})
    self:outlet(1,"float",{apcGrid[list[2]+1][list[1]+1]})
    self:outlet(1,"float",{list[3]})
  end

  if sel == "/monome/grid/led/all" then --value
    for x=1, #apcGrid do
      for y=1, #apcGrid[x] do
        self:outlet(1,"float",{144})
        self:outlet(1,"float",{apcGrid[x][y]})
        self:outlet(1,"float",{list[1]})
      end
    end
  end

  if sel == "/monome/grid/led/row" then  --row and value
    for x=1, #apcGrid[list[1]+1] do
      self:outlet(1,"float",{144})
      self:outlet(1,"float",{apcGrid[list[1]+1][x]})
      self:outlet(1,"float",{list[2]})
    end
  end

  if sel == "/monome/grid/led/col" then  --row and value
    for x=1, #apcGrid do
      self:outlet(1,"float",{144})
      self:outlet(1,"float",{apcGrid[x][list[1]+1]})
      self:outlet(1,"float",{list[2]})
    end
  end

  if sel == "/monome/grid/led/level/row" then  --row and value /grid/led/level/row x_off y l[..]
    for x=1, #apcGrid[list[2]+1] do
      self:outlet(1,"float",{144})
      self:outlet(1,"float",{apcGrid[list[2]+1][x]})
      self:outlet(1,"float",{brightness(list[x+2])})
    end
  end
end

function apcnome:in_2(sel,list)
  if list[1]<64 then
    local x,y,vel = notecoord(list[1],list[2])
    if vel ~= 0 then
      vel = 1
    else
      vel = 0
    end
    self:outlet(2,"list",{"/monome/grid/key",x,y,vel})
  end
end
