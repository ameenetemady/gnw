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

  function sbmlUtil.getTFs(strXmlFilename, taNet)
    if taNet == nil then
      taNet = sbmlUtil.getNetFromSbml(strXmlFilename)
    end

  end

  return sbmlUtil
end
