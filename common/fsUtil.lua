local fsUtil = {}

do
  function fsUtil.getDirname(strFilename)
    local command = "dirname " .. strFilename
    local fHandle = io.popen(command, "r")
    local strRes = fHandle:read("*l")

    return strRes
  end

  function fsUtil.getFilename(strFilename)
    local command = "basename " .. strFilename
    local fHandle = io.popen(command, "r")
    local strRes = fHandle:read("*l")

    return strRes

  end

  return fsUtil
end


