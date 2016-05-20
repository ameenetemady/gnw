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

end

function KOExprMgr:getNextExpr()

end

function KOExprMgr:run()

end

function KOExprMgr:aggregate()

end
