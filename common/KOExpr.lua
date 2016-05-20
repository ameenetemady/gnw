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
  if taKOGenes == nil or type(taKOGenes) ~= "table" or table.getn(taKOGenes) == 0 then
    return "default"
  end

  return "KO_" .. table.concat(self.taKOGenes, "_")
end

function KOExpr:init()
  -- create dir
  self.strParentDir = fsUtil.getDirname(self.strParentXmlFilename)
  self.strExprDir = string.format("%s/%s", self.strParentDir, self:getExprName())
  lfs.mkdir(self.strExprDir)

  -- copy base files
  self.strExprXmlFilename = string.format("cp %s %s", self.strParentXmlFilename, self.strExprDir)
  self.strExprGnwSettingsFilename = string.format("cp %s %s", self.taExprParams.strGnwSettingsFilename, self.strExprDir)
  os.execute(self.strExprXmlFilename)
  os.execute(self.strExprGnwSettingsFilename)

  -- KnockOut on sbml
  sbmlUtil.doInplaceGeneKnockOut(self.strExprXmlFilename, self.taKOGenes) -- todo: implement

  -- generate multifactorial perturbations on TFs
  --todo: implement

end

function KOExpr:__tostring()
  local str = "file:" .. self.strParentXmlFilename .. ", "
  
  str = str .. "KO:" .. table.concat(self.taKOGenes, ", ")

  return str
end
