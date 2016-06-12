require 'xml'
local lfs = require 'lfs'
local sbmlUtil = require('./sbmlUtil.lua')
require('./GnwNetPerturb.lua')
require('./KOExprMgr.lua')
require('../../mygithub/MyCommon/PermutationGenerator.lua')

function main(strNetMainFilename, nNets, taExprParams)
  --todo: assert file exists

  for seed=1, nNets do
    local strNetCurrPerturbedFilename = sbmlUtil.genPerturbedNet(strNetMainFilename, seed)
    local koExprMgr = KOExprMgr.new(strNetCurrPerturbedFilename, taExprParams)
    koExprMgr:init()

    while koExprMgr:hasMore()  do
      local currExpr = koExprMgr:nextExpr()
      currExpr:run()
    end

    koExprMgr:aggregate()
  end

end
-- arg1: xmlfile, arg2: number of random nets, arg3: step size
local taExprParams = { nMinKO = 1, nMaxKO = 1, dMultiFactorialStep= arg[3] or 0.1, strGnwSettingsFilename = "settings.txt" }
main(arg[1], arg[2] or 1, taExprParams)
