local xml = require 'LuaXML'
require('./KOExpr.lua')

local myUtil = myUtil or require('../../MyCommon/util.lua')
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

function KOExprMgr:pri_saveAggregated_KO(strFilename)
  local teAggr = self:pri_aggr(function(currExpr)  return currExpr:getProcessed_KO() end)

  --Create Header
  local taNonTFs = sbmlUtil.getNonTFs(self.strXmlFilename)

  myUtil.saveTensorAndHeaderToCsvFile(teAggr, taNonTFs, strFilename)
end

function KOExprMgr:pri_saveAggregated_TF(isNoNoise, strFilename)
  -- read the file into tensor
  local teAggr = self:pri_aggr(function(currExpr)  return currExpr:getProcessed_TF(isNoNoise) end)
  
  -- Create Header
  local taTFs = sbmlUtil.getTFs(self.strXmlFilename)
 
  myUtil.saveTensorAndHeaderToCsvFile(teAggr, taTFs, strFilename)
end

function KOExprMgr:pri_saveAggregated_NonTF(isNoNoise, strFilename)
  -- read the file into tensor
  local teAggr = self:pri_aggr(function(currExpr)  return currExpr:getProcessed_NonTF(isNoNoise) end)
  
  -- Create Header
  local taNonTFs = sbmlUtil.getNonTFs(self.strXmlFilename)
 
  myUtil.saveTensorAndHeaderToCsvFile(teAggr, taNonTFs, strFilename)
end

function KOExprMgr:getTaAggrFilenames()
  local strDir = fsUtil.getDirname(self.strXmlFilename)
  local taRes = { strKO = string.format("%s/processed_KO.tsv", strDir),
                  strTFs = string.format("%s/processed_TFs.tsv", strDir),
                  strTFsNoNoise = string.format("%s/processed_TFsNoNoise.tsv", strDir),
                  strNonTFs = string.format("%s/processed_NonTFs.tsv", strDir),
                  strNonTFsNoNoise = string.format("%s/processed_NonTFsNoNoise.tsv", strDir)
                }

  return taRes
end

function KOExprMgr:aggregate()
  self.taAggrFilenames = self:getTaAggrFilenames()

  self:pri_saveAggregated_KO(self.taAggrFilenames.strKO)

  self:pri_saveAggregated_TF(false, self.taAggrFilenames.strTFs)

  self:pri_saveAggregated_TF(true, self.taAggrFilenames.strTFsNoNoise)

  self:pri_saveAggregated_NonTF(false, self.taAggrFilenames.strNonTFs)

  self:pri_saveAggregated_NonTF(true, self.taAggrFilenames.strNonTFsNoNoise)

end
