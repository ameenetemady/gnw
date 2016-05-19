require('./GnwNetPerturb.lua')
require('./KOExprMgr.lua')
local sbmlUtil = require('./sbmlUtil.lua')
local lfs = require 'lfs'

local unitTests = {}
local utSettings = { testDir = "appUT", baseDir= lfs.currentdir() }

function unitTests.sbmlUtil_genPerturbedNet_t1()
    local strNetCurrPerturbedFilename = sbmlUtil.genPerturbedNet('feedforward1.xml', 1)
    assert(strNetCurrPerturbedFilename == "./d_1/feedforward1.xml", "unexpected result in genPerturbedNet_t1")

end

function unitTests.sbmlUtil_getGeneNames_t1()
  local strXmlFilename = "feedforward1.xml"
  local taGenes = sbmlUtil.getGeneNames(strXmlFilename)

  assert(table.getn(taGenes) == 3, "unexpected result")
end

function unitTests.sbmlUtil_getGeneNames_t1()
  local strXmlFilename = "feedforward1.xml"
  local taGenes = sbmlUtil.getTFs(strXmlFilename)

  assert(table.getn(taGenes) == 1, "unexpected result")

end

function unitTests.sbmlUtil_getNetFromSbml_t1()
  local strXmlFilename = "feedforward1.xml"
  local taNet = sbmlUtil.getNetFromSbml(strXmlFilename)

  print(taNet)
end

function unitTests.KOExprMgr_init_t1()
  local taExprParams = { nMinKO = 1, nMaxKO = 1, dMultiFactorialStep=0.1 }

  local koExprMgr = KOExprMgr.new("feedforward1.xml", taExprParams)
  koExprMgr:init()
end

function wrapUT(fuUT, strName)
  lfs.chdir(utSettings.testDir)
  
  fuUT()

  print("PASS " .. strName)
  lfs.chdir(utSettings.baseDir)
end

--wrapUT(unitTests.sbmlUtil_genPerturbedNet_t1, "sbmlUtil_genPerturbedNet_t1")
--wrapUT(unitTests.sbmlUtil_getGeneNames_t1, "sbmlUtil_getGeneNames_t1")
--wrapUT(unitTests.sbmlUtil_getTFs_t1, "sbmlUtil_getTFs_t1")
--wrapUT(unitTests.sbmlUtil_getNetFromSbml_t1, "sbmlUtil_getNetFromSbml_t1")
wrapUT(unitTests.KOExprMgr_init_t1, "KOExprMgr_init_t1")
