local myUtil = myUtil or require('../../mygithub/MyCommon/util.lua')

local sbmlUtil = {}

do
  function sbmlUtil.genPerturbedNet(strNetMainFilename, seed)

    local settings = { baseDir = currDir, 
                       xmlFilename = strNetMainFilename}

    local pertNet = GnwNetPerturb.new(settings, seed)
    pertNet:init()
    pertNet:randomize()

    return pertNet.xmlFilename
  end

  function sbmlUtil.getGeneNames(strXmlFilename)
    local xRoot = xml.load(strXmlFilename)
    local xSpecies = xRoot:find("listOfSpecies")

    taGenes = {}
    for k, v in pairs(xSpecies) do
      if type(v) == "table" and v.name ~= "_void_" then
        table.insert(taGenes, v.name)
      end
    end

    table.sort(taGenes)

    return taGenes
  end

  function sbmlUtil.getNetFromSbml(strXmlFilename)
    local taGeneNames = sbmlUtil.getGeneNames(strXmlFilename)
    local taNet = {}
    local xRoot = xml.load(strXmlFilename)

    for k, v in pairs(taGeneNames) do
      taNet[v] = "TF"
      local xReaction = xRoot:find("reaction", "id", v .. "_synthesis")
      local xModifiers = xReaction:find("listOfModifiers")

      if xModifiers ~= nil then
        taNet[v] = {}
        for mk, mv in pairs(xModifiers) do
          if type(mv) == "table" then
            table.insert(taNet[v], mv.species)
          end
        end
      end

    end

    return taNet
  end

  function sbmlUtil.getMultifactorialPerts(strXmlFilePath, taExprParams)
    local taNet = sbmlUtil.getNetFromSbml(strXmlFilePath)
    local taGenes = sbmlUtil.getGeneNames(strXmlFilePath)

    -- initialize
    local nGenes = table.getn(taGenes)
    local taPertMins = {}
    local taPertMaxs = {}
    local nLevels = 1/(taExprParams.dMultiFactorialStep)

    -- set permutation boundaries
    for i=1, nGenes do
      local strGene = taGenes[i]
      if taNet[strGene] == "TF" then
        taPertMins[i] = -nLevels
        taPertMaxs[i] = nLevels
      else
        taPertMins[i] = 0
        taPertMaxs[i] = 0
      end
    end
    
    -- permute
    local permutGen = PermutationGenerator(taPertMins, taPertMaxs)
    local tePerm = permutGen:getNext()
    local taAll = {}
    while tePerm ~= nil do
     table.insert(taAll, tePerm:clone())
     tePerm = permutGen:getNext()
    end

    -- save
    local teAll = myUtil.getTensorFromTableOfTensors(taAll)
    teAll:mul(taExprParams.dMultiFactorialStep)
    local strContent = myUtil.getCsvStringFrom2dTensor(teAll, "\t")
    local strHeader = table.concat(taGenes, "\t")

    return string.format("%s\n%s", strHeader, strContent)
  end

  function sbmlUtil.doInplaceGeneKnockOut(strXmlFilename, taKOGenes)
    local xRoot = xml.load(strXmlFilename)

    for k, strGene in pairs(taKOGenes) do
       local xReaction = xRoot:find("reaction", "id", strGene .. "_synthesis")
       local xParamMax = xReaction:find("kineticLaw"):find("listOfParameters"):find("parameter", "id", "max")
       xParamMax.value = 0.0
    end

    xRoot:save(strXmlFilename)
  end

  function sbmlUtil.getTFs(strXmlFilename, taNet)
    if taNet == nil then
      taNet = sbmlUtil.getNetFromSbml(strXmlFilename)
    end
    
    local taRes = {}
    for k, v in pairs(taNet) do
      if v == "TF" then
        table.insert(taRes, k)
      end
    end

    table.sort(taRes)
    return taRes
  end


  function sbmlUtil.getNonTFs(strXmlFilename, taNet)
    if taNet == nil then
      taNet = sbmlUtil.getNetFromSbml(strXmlFilename)
    end
    
    local taRes = {}
    for k, v in pairs(taNet) do
      if v ~= "TF" then
        table.insert(taRes, k)
      end
    end

    table.sort(taRes)
    return taRes
  end


  return sbmlUtil
end
