print('start')
local p='C:/Users/Gabriel/orca/workspaces/GAME/codex-orion-basico/Two Souls/art/orion.aseprite'
local ok, spr=pcall(function() return Sprite{fromFile=p} end)
print('result='..tostring(ok)..' '..tostring(spr))
if spr then print('size='..spr.width..'x'..spr.height) end