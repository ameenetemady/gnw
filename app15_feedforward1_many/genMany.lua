local lfs = require 'lfs'
require('./GnwNet')

local currDir = lfs.currentdir()
local settings = { baseDir = currDir, 
                   templateDir = currDir .. "/template",
                   xmlFilename = "feedforward1.xml"}

local nNets = 100
for i=1, nNets do
  local currNet = GnwNet.new(settings, i)
  currNet:init()
  currNet:randomize()
  currNet:run()
end
