require('./GnwNetPerturb.lua')
require('./KOExprMgr.lua')
require('../../mygithub/MyCommon/PermutationGenerator.lua')

local sbmlUtil = require('./sbmlUtil.lua')
local lfs = require 'lfs'

local unitTests = {}
local utSettings = { testDir = "appUT", baseDir= lfs.currentdir() }

function wrapUT(fuUT, strName)
  lfs.chdir(utSettings.testDir)
  
  fuUT()

  print("PASS " .. strName)
  lfs.chdir(utSettings.baseDir)
end


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

function unitTests.sbmlUtil_doInplaceGeneKnockOut_t1()
  sbmlUtil.doInplaceGeneKnockOut("feedforward1.xml", {"G7"})
end

function unitTests.sbmlUtil_getMultifactorialPerts_t1()
    local taExprParams = { nMinKO = 1, nMaxKO = 1, dMultiFactorialStep=0.1, strGnwSettingsFilename = "settings.txt" }
    local strPerts = sbmlUtil.getMultifactorialPerts(".", "feedforward1.xml", taExprParams)
    print(strPerts)
end

function unitTests.KOExprMgr_init_t1()
  local taExprParams = { nMinKO = 1, nMaxKO = 1, dMultiFactorialStep=0.1, strGnwSettingsFilename = "settings.txt" }

  local koExprMgr = KOExprMgr.new("feedforward1.xml", taExprParams)
  koExprMgr:init()
end

function unitTests.KOExprMgr_E2E_t1()
  local taExprParams = { nMinKO = 1, nMaxKO = 1, dMultiFactorialStep=0.1, strGnwSettingsFilename = "settings.txt" }

  local koExprMgr = KOExprMgr.new("feedforward1.xml", taExprParams)
  koExprMgr:init()

  while koExprMgr:hasMore()  do
    local currExpr = koExprMgr:nextExpr()
--    currExpr:run()
  end

  koExprMgr:aggregate()
end

function unitTests.KOExpr_run_E2ETest()
  local taExprParams = { nMinKO = 1, nMaxKO = 1, dMultiFactorialStep=0.1, strGnwSettingsFilename = "settings.txt" }
  local koExpr = KOExpr.new("feedforward1.xml", taExprParams, {"G6"})
  print(koExpr)
  koExpr:init()
end

--wrapUT(unitTests.sbmlUtil_genPerturbedNet_t1, "sbmlUtil_genPerturbedNet_t1")
--wrapUT(unitTests.sbmlUtil_getGeneNames_t1, "sbmlUtil_getGeneNames_t1")
--wrapUT(unitTests.sbmlUtil_getTFs_t1, "sbmlUtil_getTFs_t1")
--wrapUT(unitTests.sbmlUtil_getNetFromSbml_t1, "sbmlUtil_getNetFromSbml_t1")
--wrapUT(unitTests.sbmlUtil_doInplaceGeneKnockOut_t1, "sbmlUtil_doInplaceGeneKnockOut_t1")
--wrapUT(unitTests.KOExprMgr_init_t1, "KOExprMgr_init_t1")
wrapUT(unitTests.KOExprMgr_E2E_t1, "KOExprMgr_init_t1")
--wrapUT(unitTests.KOExpr_run_E2ETest, "KOExpr_run_E2ETest")
--wrapUT(unitTests.sbmlUtil_getMultifactorialPerts_t1, "sbmlUtil_getMultifactorialPerts_t1")
