local keybuf = {}
local durbuf = {}
local mlor = pd.Class:new():register("mlorCtl")

for x = 1, 8 do
  durbuf[x-1] = 8
end

function mlor:initialize(name, atoms)
  self.outlets = 2
  self.inlets = 2
  return true
end

function mlor:in_2(sel,list)
  if sel == "/monome/grid/key" then
    pd.post(sel..list[1]..list[2]..list[3])

    if list[3] == 1 then
      if keybuf[list[2]] == nil  then
        keybuf[list[2]] = {list[1]}
        --keybuf[list[2]] = {list[1]}
      else
        table.insert(keybuf[list[2]],list[1])
      end

    elseif list[3] == 0 then
      if #keybuf[list[2]] > 1 then
        local firstkey = keybuf[list[2]][1]
        local secondkey = keybuf[list[2]][2]
        if firstkey > secondkey then
          --the first is larger than second, so rev -1 and min max
          self:outlet(2,"list",{"min", secondkey})
          self:outlet(2,"list",{"max", firstkey})
          self:outlet(2,"list",{"rev", -1})
          durbuf[list[2]] = firstkey - secondkey --setting the new dur of the subloop
        else
          self:outlet(2,"list",{"min", firstkey})
          self:outlet(2,"list",{"max", secondkey})
          self:outlet(2,"list",{"rev", 1})
          durbuf[list[2]] = secondkey - firstkey --setting the new dur of the subloop
        end
      else
        local relativegoto = list[1]/durbuf[list[2]]
        self:outlet(2,"goto",{relativegoto})
      end
      keybuf[list[2]] = {}
    end
  end
end
