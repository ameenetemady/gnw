require 'xml'
local lfs = require 'lfs'
local fsUtil = require('./fsUtil.lua')
local sbmlUtil = require('./sbmlUtil.lua')
local myUtil = myUtil or require('../../MyCommon/util.lua')
local dataLoad = dataLoad or require('../../MyCommon/dataLoad.lua')

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

  self.strTargetFilename = string.format("%s/%s_multifactorial.tsv", 
                                       self.strExprDir, 
                                       fsUtil.getFilenameNoSuffix(self.strParentXmlFilename, ".xml"))

  self.strTargetFilenameNoNoise = string.format("%s/%s_noexpnoise_multifactorial.tsv", 
                                       self.strExprDir, 
                                       fsUtil.getFilenameNoSuffix(self.strParentXmlFilename, ".xml"))

                                     
  -- knockOut on sbml
  sbmlUtil.doInplaceGeneKnockOut(self.strExprXmlFilename, self.taKOGenes)

  -- generate multifactorial perturbations on TFs
  if self.taExprParams.nPerms then
    sbmlUtil.getAndSaveRandMultifactorialPerts(self.strExprXmlFilename, self.taExprParams.nPerms, self.strPertFilename)
  else
    sbmlUtil.getAndSaveMultifactorialPerts(self.strExprXmlFilename, self.taExprParams.dMultiFactorialStep, self.strPertFilename)
  end
end

function KOExpr:run()
  local strOrigDir = lfs.currentdir()
  lfs.chdir(self.strExprDir)

  local command = string.format("./%s %s", self.strRunScripFilename, fsUtil.getFilename(self.strParentXmlFilename))
  assert(os.execute(command), "command failed!")

  lfs.chdir(strOrigDir)
end

function KOExpr:pri_getKOVector()
  local taNonTFs= sbmlUtil.getNonTFs(self.strParentXmlFilename)
  local nNonTFs = table.getn(taNonTFs)
  local teRes = torch.Tensor(1, nNonTFs)

  for i=1, nNonTFs do
    if myUtil.isInTaValues(taNonTFs[i], self.taKOGenes) then
      teRes[1][i] = 0
    else
      teRes[1][i] = 1
    end
  end

  return teRes
end

function KOExpr:getProcessed_KO()
  local nRecords = myUtil.getNumLines(self.strTargetFilename) - 1
  local teKOVector = self:pri_getKOVector()
  local teRes = torch.repeatTensor(teKOVector, nRecords, 1)

  return teRes
end

function KOExpr:getProcessed_TF(isNoNoise)
  local taTFs = sbmlUtil.getTFs(self.strParentXmlFilename)

  local taLoadParam = { strFilename = isNoNoise and self.strTargetFilenameNoNoise or self.strTargetFilename, 
                        nCols = table.getn(taTFs), taCols = taTFs, isHeader = true }
  local teData = dataLoad.loadTensorFromTsv(taLoadParam)

  return teData
end


function KOExpr:getProcessed_NonTF(isNoNoise)
  local taNonTFs = sbmlUtil.getNonTFs(self.strParentXmlFilename)

  local taLoadParam = { strFilename = isNoNoise and self.strTargetFilenameNoNoise or self.strTargetFilename, 
                        nCols = table.getn(taNonTFs), taCols = taNonTFs, isHeader = true }
  local teData = dataLoad.loadTensorFromTsv(taLoadParam)

  return teData
end

function KOExpr:__tostring()
  local str = "file:" .. self.strParentXmlFilename .. ", "
  
  str = str .. "KO:" .. table.concat(self.taKOGenes, ", ")

  return str
end
