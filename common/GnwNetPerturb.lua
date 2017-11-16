require 'xml'
local lfs = require 'lfs'
local GnwNetPerturb = torch.class('GnwNetPerturb')

function GnwNetPerturb:__init(settings, seed)
  self.seed = seed
  settings.baseDir = settings.baseDir or "."
  self.settings = settings

  self.netId = "d_" .. seed
  self.baseDir = string.format("%s/%s", settings.baseDir, self.netId)
  self.xmlFilename = string.format("%s/%s/%s", settings.baseDir, self.netId, settings.xmlFilename)
  self.gnwPath = "../gnw-3.1.2b.jar"
end

function GnwNetPerturb:pri_genBase()
  lfs.mkdir(self.baseDir)
  tsvFilePath = string.format("%s/%s.tsv", self.settings.baseDir, self.settings.xmlFilename:sub(1, -5))
  
   -- Convert .tsv file to .sbml
  local command = string.format("java -jar %s --transform -c settings.txt --input-net %s --output-net-format=4 --output-path=%s",
                                self.gnwPath, tsvFilePath, self.baseDir)
  os.execute(command)
end

function GnwNetPerturb:pri_fgetMinMax(strId)
  local prefix = string.sub(strId, 1, 2)

  -- The following ranges worked well for app19_feedforward1
  if strId == "a_0" then
    return false, 0.0, 0.8
  elseif prefix == "a_" then
    return false, 0, 0.4 
  elseif prefix == "k_" then
    return false, 10 , 15
  elseif prefix == "n_" then
    return false, 0.5, 3
  elseif strId == "max" then
    return false, 0.01, 0.5
  else
    return true 
  end

end

function GnwNetPerturb:pri_randomizeParam(v)
  local isReadOnly, min, max = self:pri_fgetMinMax(v.id)

  if not isReadOnly then
    v.value = math.random()*(max-min) + min
  end

end

function GnwNetPerturb:pri_randomizeReaction(xReaction)
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

function GnwNetPerturb:init()
  self:pri_genBase()
end

function GnwNetPerturb:randomize()
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
