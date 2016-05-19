local util = {}

do
  function util.genPerturbedNet(strNetMainFilename, seed)

    local settings = { baseDir = currDir, 
                       xmlFilename = strNetMainFilename}

    local pertNet = GnwNetPerturb.new(settings, seed)
    pertNet:init()
    pertNet:randomize()

    return pertNet.xmlFilename
  end

  return util
end
