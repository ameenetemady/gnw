require 'xml'
require('./KOExpr.lua')

local sbmlUtil = require("./sbmlUtil.lua")

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

  self.taKOExperiments = {}
  local currKOExpr = KOExpr.new(self.strXmlFilename, self.taExprParams, {})
  currKOExpr:init()

  table.insert(self.taKOExperiments, currKOExpr)
  self.nTotalKOExpr = 1

  -- Single KO only:
  for strGene, taTFs in pairs(self.taNet) do
    if type(taTFs) == "table" then
      local currKOExpr = KOExpr.new(self.strXmlFilename, self.taExprParams, {strGene})
      print(currKOExpr)
      currKOExpr:init()
      table.insert(self.taKOExperiments, currKOExpr)
      self.nTotalKOExpr = self.nTotalKOExpr + 1
    end
  end
end

function KOExprMgr:hasMore()
  return self.nLastExprId < self.nTotalKOExpr
end

function KOExprMgr:nextExpr()
  self.nLastExprId = self.nLastExprId + 1
  return self.taKOExperiments[self.nLastExprId]
end

function KOExprMgr:pri_getAggregated_KO()
  local teAggr = nil

  --Aggregate
  for i=1, self.nTotalKOExpr do
    local currExpr = self.taKOExperiments[i]
    local teCurr = currExpr:getProcessed_KO()

    if teAggr == nil then
      teAggr = teCurr
    else
      teAggr = torch.cat(teAggr, teCurr, 1)
    end
  end

  --Create Header
  local taNonTFs={}
  for strGene, taTFs in pairs(self.taNet) do
    if taTFs ~= "TF" then
      table.insert(taNonTfs, strGene)
    end
  end

  --Prepare to Return
  local strHeader = table.concat(taNonTFs, "\t")
  local strContent = myUtil.getCsvStringFrom2dTensor(teAggr, "\t")

 return string.format("%s\n%s", strHeader, strContent)
end

function KOExprMgr:pri_getAggregated_TF()

end

function KOExprMgr:pri_getAggregated_NonTF()

end

function KOExprMgr:aggregate()
  local strAggrKO = self:pri_getAggregated_KO()
  print(strAggrKO)
  --todo implement, save

  local strAggrTF = self:pri_getAggregated_TF()

  local strAggrNonTF = self:pri_getAggregated_NonTF()
end
