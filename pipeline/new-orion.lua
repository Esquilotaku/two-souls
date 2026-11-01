-- Cria um .aseprite vazio do Orion seguindo docs/folha-de-estilo-orion.md:
-- 128x96, modo indexado com a paleta fixa, 12 quadros por segundo e uma tag por animação.
-- Uso: aseprite -b --script-param dst="Two Souls\art\orion-novo.aseprite" --script pipeline\new-orion.lua
-- Opcional: --script-param palette=caminho.gpl (padrão: "Two Souls/art/orion-paleta.gpl" ao lado deste script).
-- Não sobrescreve arquivo existente.
local dst = app.params["dst"]
if not dst or dst == "" then error("Informe --script-param dst=saida.aseprite") end
if app.fs.isFile(dst) then error("Já existe: " .. dst .. " (apague ou escolha outro nome)") end

local scriptDir = app.fs.filePath(debug.getinfo(1, "S").source:sub(2))
local palettePath = app.params["palette"]
  or app.fs.joinPath(app.fs.filePath(scriptDir), "Two Souls/art/orion-paleta.gpl")
if not app.fs.isFile(palettePath) then error("Paleta não encontrada: " .. palettePath) end

local WIDTH, HEIGHT = 128, 96
local HEAD_Y, FOOT_Y, PIVOT_X = 16, 88, 64 -- Orion com 72 px, pé em (64, 88)
local FRAME_SECONDS = 1 / 12

-- Ordem, nome da tag e quadros (folha de estilo, seção Animações).
local ANIMATIONS = {
  { name = "idle",   frames = 6, loop = true  },
  { name = "run",    frames = 8, loop = true  },
  { name = "jump",   frames = 3, loop = false },
  { name = "fall",   frames = 2, loop = true  },
  { name = "attack", frames = 6, loop = false },
  { name = "dash",   frames = 4, loop = false },
}

local total = 0
for _, anim in ipairs(ANIMATIONS) do total = total + anim.frames end

local sprite = Sprite(WIDTH, HEIGHT, ColorMode.INDEXED)
sprite:setPalette(Palette{ fromFile = palettePath })
sprite.transparentColor = 0

-- Camadas: a lança separada do corpo e uma guia escondida (não vai para o export).
sprite.layers[1].name = "corpo"
local spear = sprite:newLayer()
spear.name = "lanca"
local guide = sprite:newLayer()
guide.name = "guia"

for _ = 2, total do sprite:newEmptyFrame() end
for _, frame in ipairs(sprite.frames) do frame.duration = FRAME_SECONDS end

local first = 1
for _, anim in ipairs(ANIMATIONS) do
  local tag = sprite:newTag(first, first + anim.frames - 1)
  tag.name = anim.name
  if not anim.loop then tag.repeats = 1 end
  first = first + anim.frames
end

-- Guia: linha da cabeça, linha do pé e eixo do pivô, na cor "brilho 2" (índice 27).
local guideImage = Image(WIDTH, HEIGHT, ColorMode.INDEXED)
for x = 0, WIDTH - 1 do
  guideImage:drawPixel(x, HEAD_Y, 27)
  guideImage:drawPixel(x, FOOT_Y, 27)
end
for y = HEAD_Y, FOOT_Y do guideImage:drawPixel(PIVOT_X, y, 27) end
for _, frame in ipairs(sprite.frames) do sprite:newCel(guide, frame, guideImage) end
guide.isVisible = false

sprite:saveAs(dst)
sprite:close()
print(string.format("Criado: %s (%dx%d, %d quadros, %d tags)", dst, WIDTH, HEIGHT, total, #ANIMATIONS))
