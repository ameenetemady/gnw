require 'xml'
local KOExpr= torch.class('KOExpr')

function KOExpr:__init(strXmlFilename, taExprParams, taKOGenes)
  self.strXmlFilename = strXmlFilename
  self.taExprParams = taExprParams
  self.taKOGenes = taKOGenes
end

function KOExpr:__tostring()
end
