require 'xml'
local lfs = require 'lfs'
local GnwNet = torch.class('GnwNet')

function GnwNet:pri_genBase()
  command = "cp -a " .. self.settings.templateDir .. " " .. self.baseDir
  os.execute(command)
end

function GnwNet:pri_getRands(seed)

end

function GnwNet:pri_fgetMinMax(strId)
  local prefix = string.sub(strId, 1, 2)

  -- The following ranges worked well for app19_feedforward1:
  if prefix == "a_" then
    return false, 0, 1
  elseif prefix == "k_" then
    return false, 0.9, 5
  elseif prefix == "n_" then
    return false, 1, 7
  else
    return true 
  end

end

function GnwNet:pri_randomizeParam(v)
  local isReadOnly, min, max = self:pri_fgetMinMax(v.id)

  if not isReadOnly then
    v.value = math.random()*(max-min) + min
  end

end

function GnwNet:pri_randomizeReaction(xReaction)
  local xModifiers = xReaction:find("listOfModifiers")
  if xModifiers == nil then -- skip for the genes with no modifier
    return
  end

  local xParamList = xReaction:find("kineticLaw"):find("listOfParameters")

  for k, v in pairs(xParamList) do
    if type(v) == "table" then
       self:pri_randomizeParam(v)
    end
  end


end

function GnwNet:__init(settings, seed)
  self.seed = seed
  self.settings = settings

  self.netId = "d_" .. seed
  self.baseDir = string.format("%s/%s", settings.baseDir, self.netId)
  self.xmlFilename = string.format("%s/%s/%s", settings.baseDir, self.netId, settings.xmlFilename)
end

function GnwNet:init()
  self:pri_genBase()
end

function GnwNet:randomize()
  torch.manualSeed(self.seed)

  local xRoot = xml.load(self.xmlFilename)
  local xReactions = xRoot:find("listOfReactions")

  for k, v in pairs(xReactions) do
    if type(v) == "table" then
      self:pri_randomizeReaction(v)
    end
  end

  xRoot:save(self.xmlFilename)
  print(string.format("saved %s", self.xmlFilename))

end

function GnwNet:run()
  lfs.chdir(self.baseDir)
  os.execute("./run.sh")
  lfs.chdir(self.settings.baseDir)
  
end
