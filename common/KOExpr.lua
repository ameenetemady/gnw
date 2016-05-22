require 'xml'
local lfs = require 'lfs'
local fsUtil = require('./fsUtil.lua')
local sbmlUtil = require('./sbmlUtil.lua')

local KOExpr = torch.class('KOExpr')

function KOExpr:__init(strParentXmlFilename, taExprParams, taKOGenes)
  self.strParentXmlFilename = strParentXmlFilename
  self.taExprParams = taExprParams
  self.taKOGenes = taKOGenes
end

function KOExpr:getExprName()
  if self.taKOGenes == nil or type(self.taKOGenes) ~= "table" or table.getn(self.taKOGenes) == 0 then
    return "default"
  end

  return "KO_" .. table.concat(self.taKOGenes, "_")
end

function KOExpr:init()
  -- create dir
  self.strParentDir = fsUtil.getDirname(self.strParentXmlFilename)
  self.strExprDir = string.format("%s/%s", self.strParentDir, self:getExprName())
  print("mkdir: " .. self.strExprDir)
  lfs.mkdir(self.strExprDir)

  -- copy base files
  local command = nil
  command = string.format("cp %s %s", self.strParentXmlFilename, self.strExprDir)
  assert(os.execute(command), "command failed!")

  command = string.format("cp %s %s", self.taExprParams.strGnwSettingsFilename, self.strExprDir)
  assert(os.execute(command), "command failed!")

  command = string.format("cp %s %s", "run.sh", self.strExprDir)
  assert(os.execute(command), "command failed!")


  self.strExprXmlFilename = string.format("%s/%s", self.strExprDir, fsUtil.getFilename(self.strParentXmlFilename))
  self.strExprGnwSettingsFilename = string.format("%s/%s", self.strExprDir, self.taExprParams.strGnwSettingsFilename)
  self.strRunScripFilename = "run.sh"
  self.strPertFilename = string.format("%s/%s_multifactorial_perturbations.tsv", 
                                       self.strExprDir, 
                                       fsUtil.getFilenameNoSuffix(self.strParentXmlFilename, ".xml"))
                                     
  -- knockOut on sbml
  sbmlUtil.doInplaceGeneKnockOut(self.strExprXmlFilename, self.taKOGenes)

  -- generate multifactorial perturbations on TFs
  local strPerts = sbmlUtil.getMultifactorialPerts(self.strExprXmlFilename, self.taExprParams)
  fsUtil.writeStrToFile(strPerts, self.strPertFilename)
end

function KOExpr:run()
  local strOrigDir = lfs.currentdir()
  lfs.chdir(self.strExprDir)

  local command = string.format("./%s %s", self.strRunScripFilename, fsUtil.getFilename(self.strParentXmlFilename))
  assert(os.execute(command), "command failed!")

  lfs.chdir(strOrigDir)
end

function KOExpr:getProcessed_KO()
  --todo: continue implement here ...
end

function KOExpr:__tostring()
  local str = "file:" .. self.strParentXmlFilename .. ", "
  
  str = str .. "KO:" .. table.concat(self.taKOGenes, ", ")

  return str
end
