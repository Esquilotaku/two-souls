local src='C:/Users/Gabriel/orca/workspaces/GAME/codex-orion-basico/Two Souls/art/rascunhos/orion-idle-rascunho.png'
local dst='C:/Users/Gabriel/orca/workspaces/GAME/codex-orion-basico/Two Souls/art/rascunhos/gui-test.aseprite'
local sprite=Sprite{fromFile=src}
print('sprite='..tostring(sprite)..' dims='..tostring(sprite.width)..'x'..tostring(sprite.height))
sprite:saveAs(dst)
sprite:close()
print('saved '..dst)