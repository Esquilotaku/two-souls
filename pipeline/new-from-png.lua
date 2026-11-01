-- Cria um .aseprite a partir de um PNG, com uma tag cobrindo o quadro.
-- Uso: aseprite -b --script-param src=entrada.png --script-param dst=saida.aseprite --script-param tag=idle --script pipeline\new-from-png.lua
local src = app.params["src"]
local dst = app.params["dst"]
local tagName = app.params["tag"] or "idle"

local sprite = Sprite{ fromFile = src }
local tag = sprite:newTag(1, #sprite.frames)
tag.name = tagName
sprite:saveAs(dst)
sprite:close()
print("Criado: " .. dst)
