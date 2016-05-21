local fsUtil = {}

do
  function fsUtil.getDirname(strFilename)
    local command = "dirname " .. strFilename
    local fHandle = assert(io.popen(command, "r"))
    local strRes = fHandle:read("*l")

    return strRes
  end

  function fsUtil.getFilename(strFilename)
    local command = "basename " .. strFilename
    local fHandle = assert(io.popen(command, "r"))
    local strRes = fHandle:read("*l")

    return strRes
  end

  function fsUtil.getFilenameNoSuffix(strFilename, strSuffix)
    local command = "basename -s " .. strSuffix .. " " .. strFilename
    local fHandle = assert(io.popen(command, "r"))
    local strRes = fHandle:read("*l")

    return strRes

  end


  function fsUtil.writeStrToFile(strContent, strFilename)
    local fHandle = assert(io.open(strFilename, "w+"))
    fHandle:write(strContent)
    fHandle:close()
  end

  return fsUtil
end

