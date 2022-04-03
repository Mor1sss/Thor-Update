local username_true = {}
local username = globals.get_username()
username_true['Mor1ss'] = true
username_true['KRIPSI'] = true

local function sendtrue()
    if username_true[username] == true then
      return true
    else
      return false
    end
end

return sendtrue()
