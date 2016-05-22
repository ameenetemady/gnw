require 'xml'
require('./KOExpr.lua')

local myUtil = myUtil or require('../../mygithub/MyCommon/util.lua')
local sbmlUtil = sbmlUtil or require("./sbmlUtil.lua")
local fsUtil = fsUtil or require("./fsUtil.lua")

local KOExprMgr = torch.class('KOExprMgr')

function KOExprMgr:__init(strXmlFilename, taExprParams)
  self.strXmlFilename = strXmlFilename
  self.taExprParams = taExprParams

  self.nLastExprId = 0
  self.nTotalKOExpr = 0
end

function KOExprMgr:init()
  -- read the xml file to extract gene names and setup the experiments
  self.taNet = sbmlUtil.getNetFromSbml(self.strXmlFilename)
  self.taNonTFs = sbmlUtil.getNonTFs(self.strXmlFilename, self.taNet)

  self.taKOExperiments = {}
  local currKOExpr = KOExpr.new(self.strXmlFilename, self.taExprParams, {})
  currKOExpr:init()

  table.insert(self.taKOExperiments, currKOExpr)
  self.nTotalKOExpr = 1

  -- Single KO only:
  for k, strGene in pairs(self.taNonTFs) do
      local currKOExpr = KOExpr.new(self.strXmlFilename, self.taExprParams, {strGene})
      print(currKOExpr)
      currKOExpr:init()
      table.insert(self.taKOExperiments, currKOExpr)
      self.nTotalKOExpr = self.nTotalKOExpr + 1
  end

end

function KOExprMgr:hasMore()
  return self.nLastExprId < self.nTotalKOExpr
end

function KOExprMgr:nextExpr()
  self.nLastExprId = self.nLastExprId + 1
  return self.taKOExperiments[self.nLastExprId]
end

function KOExprMgr:pri_aggr(fuGet)
  local teAggr = nil

  for i=1, self.nTotalKOExpr do
    local currExpr = self.taKOExperiments[i]
    local teCurr = fuGet(currExpr)

    if teAggr == nil then
      teAggr = teCurr
    else
      teAggr = torch.cat(teAggr, teCurr, 1)
    end
  end

  return teAggr
end

function KOExprMgr:pri_getAggregated_KO()
  local teAggr = self:pri_aggr(function(currExpr)  return currExpr:getProcessed_KO() end)

  --Create Header
  local taNonTFs = sbmlUtil.getNonTFs(self.strXmlFilename)
 
  --Prepare to Return
  local strHeader = table.concat(taNonTFs, "\t")
  local strContent = myUtil.getCsvStringFrom2dTensor(teAggr, "\t")

 return string.format("%s\n%s", strHeader, strContent)
end

function KOExprMgr:pri_getAggregated_TF()
  -- read the file into tensor
  local teAggr = self:pri_aggr(function(currExpr)  return currExpr:getProcessed_TF() end)
  
  -- Create Header
  local taTFs = sbmlUtil.getTFs(self.strXmlFilename)
 
  -- Prepare to Return
  local strHeader = table.concat(taTFs, "\t")
  local strContent = myUtil.getCsvStringFrom2dTensor(teAggr, "\t")

  return string.format("%s\n%s", strHeader, strContent)
end

function KOExprMgr:pri_getAggregated_NonTF()
  -- read the file into tensor
  local teAggr = self:pri_aggr(function(currExpr)  return currExpr:getProcessed_NonTF() end)
  
  -- Create Header
  local taNonTFs = sbmlUtil.getNonTFs(self.strXmlFilename)
 
  -- Prepare to Return
  local strHeader = table.concat(taNonTFs, "\t")
  local strContent = myUtil.getCsvStringFrom2dTensor(teAggr, "\t")

  return string.format("%s\n%s", strHeader, strContent)
end

function KOExprMgr:getTaAggrFilenames()
  local strDir = fsUtil.getDirname(self.strXmlFilename)
  local taRes = { strKO = string.format("%s/processed_KO.tsv", strDir),
                  strTFs = string.format("%s/processed_TFs.tsv", strDir),
                  strNonTFs = string.format("%s/processed_NonTFs.tsv", strDir)}

  return taRes
end

function KOExprMgr:aggregate()
  self.taAggrFilenames = self:getTaAggrFilenames()

  local strAggrKO = self:pri_getAggregated_KO()
  fsUtil.writeStrToFile(strAggrKO, self.taAggrFilenames.strKO)

  local strAggrTF = self:pri_getAggregated_TF()
  fsUtil.writeStrToFile(strAggrTF, self.taAggrFilenames.strTFs)

  local strAggrNonTF = self:pri_getAggregated_NonTF()
  fsUtil.writeStrToFile(strAggrNonTF, self.taAggrFilenames.strNonTFs)
end
