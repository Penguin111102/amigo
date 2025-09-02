local KeysBin = MachoWebRequest("https://raw.githubusercontent.com/Penguin111102/amigo/main/keys.txt")
local CurrentKey = MachoAuthenticationKey()

if string.find(KeysBin, CurrentKey) then
    print("Key is authenticated [" .. CurrentKey .. "]")
    MachoIsolatedInject(MachoWebRequest("https://raw.githubusercontent.com/Penguin111102/amigo/main/menu_obfuscated.lua"))
else
    print("Key is not in the list [" .. CurrentKey .. "]")
end
