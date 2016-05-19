require 'xml'
local lfs = require 'lfs'
require('GnwNet')
require('KOExprMgr')

function genPerturbedNet(strNetMainFilename, seed)

  local settings = { baseDir = currDir, 
                     templateDir = currDir,
                     xmlFilename = strNetMainFilename}

  local pertNet = GnwNet.new(settings, seed)
  pertNet:init()
  pertNet:randomize()

  return pertNet

end

function main(strNetMainFilename, nNets)
  --todo: assert file exists

  for seed=1, nNets do
    local strNetCurrPerturbedFilename = genPerturbedNet(strNetMainFilename, seed)
    local koExprMgr = KOExprMgr.new(strNetCurrPerturbedFilename)

    while koExprMgr:HasMore()  do
      local currExpr = koExprMgr:getNextExpr()
      currExpr:run()
    end

    koExprMgr:Aggregate()

  end

end

local taExprParam = { nMinKO = 1, nMaxKO = 1 }
main(arg[1], arg[2] or 1, taExprParam)
