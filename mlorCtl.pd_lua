local keybuf = {}
local trackbuf = {{},{},{},{},{},{},{},{}}
--because pd doesnt like $1 as numbers...
local letter2num ={a=0,b=1,c=2,d=3,e=4,f=5,g=6,h=7}
local mlor = pd.Class:new():register("mlorCtl")

for x = 1, 8 do
   trackbuf[x].min = 0
   trackbuf[x].max = 1
   trackbuf[x].dur = 1
end

function mlor:initialize(name, atoms)
  self.outlets = 2
  self.inlets = 2
  return true
end

function mlor:in_2(sel,list)
  if sel == "/monome/grid/key" then
    local xkey, row, state = list[1], list[2], list[3]
    if state == 1 then
      if keybuf[row] == nil  then
        --if there is nothing in keybuf table, this is first key, so create table with entry
        keybuf[row] = {xkey} --x value entry
      else --else something is in keybuf for this row, so add to table
        table.insert(keybuf[row],xkey)
      end

    elseif state == 0 then
      --first check to see if multiple keys in this buf
      if #keybuf[row] > 1 then
        --now set our keys
        local firstkey = (keybuf[row][1]/8)
        local secondkey = (keybuf[row][2]/8)
        if firstkey > secondkey then
          --the first is larger than second, so rev -1 and min max
          self:outlet(2,"playctl",{row, "low", secondkey})
          self:outlet(2,"playctl",{row, "high", firstkey+(0.125)})---need to add this for gird to make sense
          self:outlet(2,"playctl",{row, "dir", -1})
          trackbuf[row+1].dur = firstkey - secondkey --setting the new dur of the subloop
          trackbuf[row+1].min = secondkey
          trackbuf[row+1].max = firstkey

        else
          self:outlet(2,"playctl",{row, "low", firstkey})
          self:outlet(2,"playctl",{row, "high", secondkey+(0.125)})
          self:outlet(2,"playctl",{row, "dir", 1})
          trackbuf[row+1].dur = secondkey - firstkey --setting the new dur of the subloop
          trackbuf[row+1].min = firstkey
          trackbuf[row+1].max = secondkey
        end
      else
        local relativegoto = (trackbuf[row+1].dur*(xkey/8))+trackbuf[row+1].min
        self:outlet(2,"playctl",{row,"goto",relativegoto})
      end
      keybuf[list[2]] = {}
    end
  end
end

function mlor:in_1(sel, list)
  -- pd.post("SEL  "..sel)
  -- pd.post("LIST[1]  "..list[1])
  --- first start list with row command, 0 offset, and the row
  local ledbuf = {"/monome/grid/led/level/row", 0, letter2num[list[1]]}
  local row = letter2num[list[1]]+1
  local currHead = list[2]
  local min, max = trackbuf[row].min*8, trackbuf[row].max*8
  for x = 1, 8 do
    if x <= min then
      ledbuf[x+3] = 0
    elseif x > max+1 then
      ledbuf[x+3] = 0
    elseif x == currHead then
      ledbuf[x+3] = 15 --keeping monome "varibright"
    else
      ledbuf[x+3] = 5
    end
  end
  self:outlet(1, "ledctl",ledbuf)
end
