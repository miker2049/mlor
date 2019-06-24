local mlor = pd.Class:new():register("mlorCtl")

function mlor:initialize(name, atoms)
  self.outlets = 2
  self.inlets = 2
  return true
end
