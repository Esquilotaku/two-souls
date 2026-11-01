-- Rebuilds the six Orion animations from the approved, already-generated horizontal PNG drafts.
-- From the repository root, first create a clean tagged seed with pipeline/new-orion.lua, then run:
-- aseprite -b --script-param src="Two Souls/art/rascunhos/orion-idle-rascunho.png" --script-param srcdir="Two Souls/art/rascunhos" --script-param seed="Two Souls/art/rascunhos/orion-seed.aseprite" --script-param dst="Two Souls/art/rascunhos/orion-rebuilt.aseprite" --script-param report="Two Souls/art/rascunhos/orion-rebuild-report.txt" --script pipeline/rebuild-orion.lua
-- In PowerShell pipe the Aseprite call to Out-Null so it finishes before checking the outputs.
-- Normalizes each independently generated sheet to the idle head size, then corrects
-- residual per-frame head variation before the shared final scale; pivot maps to (64,88).
-- Components not touching the main silhouette are removed (including detached effects).

local srcParam=app.params["src"]
local srcDir=app.params["srcdir"] or "Two Souls/art/rascunhos"
local seedPath=app.params["seed"]
local dstPath=app.params["dst"]
local reportPath=app.params["report"]
if not srcParam or not seedPath or not dstPath or not reportPath then
  error("Informe src, seed, dst e report via --script-param")
end
local palettePath="Two Souls/art/orion-paleta.gpl"
local specs={
  {name="idle",count=6}, {name="run",count=8}, {name="jump",count=3},
  {name="fall",count=2}, {name="attack",count=6}, {name="dash",count=4},
}
local W,H,PIVOT_X,FOOT_Y=160,96,64,88
local SOURCE_MARGIN=40
local report={}
local function log(s) report[#report+1]=s end

local palette=Palette{fromFile=palettePath}
local paletteColors={}
for i=1,28 do
  local c=palette:getColor(i)
  paletteColors[i]={c.red,c.green,c.blue}
end
local function alpha(p) return app.pixelColor.rgbaA(p) end
local function rgb(p) return app.pixelColor.rgbaR(p),app.pixelColor.rgbaG(p),app.pixelColor.rgbaB(p) end
local function is_body_color(p)
  if alpha(p)<=96 then return false end
  local r,g,b=rgb(p)
  -- Remove the neutral metallic spearhead from the body height estimate;
  -- the opaque body materials are warm or green. A row threshold ignores the thin shaft.
  return not (math.abs(r-g)<=16 and math.abs(g-b)<=16 and r>52)
end
local function is_skin_color(p)
  if alpha(p)<=96 then return false end
  local r,g,b=rgb(p)
  return r>=90 and g>=48 and b>=20 and r>g*1.12 and g>b*1.08
end
local function find_anchor(img,x0,x1)
  local rowCounts={}
  local top,foot=nil,nil
  for y=0,img.height-1 do
    local count=0
    for x=x0,x1 do if is_body_color(img:getPixel(x,y)) then count=count+1 end end
    rowCounts[y]=count
    if count>=8 then
      if top==nil then top=y end
      foot=y
    end
  end
  if top==nil or foot==nil then error("Corpo nao encontrado na faixa "..x0.."-"..x1) end
  local feet={}
  for y=math.max(0,foot-2),foot do
    for x=x0,x1 do if is_body_color(img:getPixel(x,y)) then feet[#feet+1]=x end end
  end
  table.sort(feet)
  local footX=feet[math.floor((#feet+1)/2)]
  local faceBottom=nil
  -- The face is the skin cluster in the upper third; exclude arms by staying near the head rows.
  for y=top,math.min(foot,top+math.floor((foot-top)*0.34)) do
    for x=x0,x1 do if is_skin_color(img:getPixel(x,y)) then faceBottom=faceBottom and math.max(faceBottom,y) or y end end
  end
  if not faceBottom then error("Pele do rosto nao encontrada na faixa "..x0.."-"..x1) end
  return footX,foot,top,foot-top+1,faceBottom-top+1
end
local referenceHeight=nil
for _,spec in ipairs(specs) do
  local path=(spec.name=="idle") and srcParam or (srcDir.."/orion-"..spec.name.."-rascunho.png")
  spec.source=Sprite{fromFile=path}
  spec.image=spec.source.cels[1].image
  spec.anchors={}
  local totalHeadHeight=0
  for fi=1,spec.count do
    local x0=math.floor((fi-1)*spec.image.width/spec.count)
    local x1=math.floor(fi*spec.image.width/spec.count)-1
    local footX,footY,topY,height,headHeight=find_anchor(spec.image,x0,x1)
    spec.anchors[fi]={footX=footX,footY=footY,topY=topY,height=height,headHeight=headHeight,x0=x0,x1=x1}
    totalHeadHeight=totalHeadHeight+headHeight
    if spec.name=="idle" and fi==1 then referenceHeight=height end
  end
  spec.meanHeadHeight=totalHeadHeight/spec.count
end
if not referenceHeight then error("Altura de referencia do idle nao foi medida") end
local scale=72/referenceHeight
local idleHeadHeight=0
for _,a in ipairs(specs[1].anchors) do idleHeadHeight=idleHeadHeight+a.headHeight end
idleHeadHeight=idleHeadHeight/specs[1].count
log(string.format("idle frame 1 body height proxy=%d px; idle mean head=%0.1f px; shared final scale=%.8f",referenceHeight,idleHeadHeight,scale))
for _,spec in ipairs(specs) do
  spec.sheetScale=idleHeadHeight/spec.meanHeadHeight
  log(string.format("%s source head mean=%.1f px; sheet normalization=%.6f",spec.name,spec.meanHeadHeight,spec.sheetScale))
end

local target=Sprite{fromFile=seedPath}
if target.width~=W or target.height~=H or target.colorMode~=ColorMode.INDEXED then
  error("Seed precisa ser 160x96 e modo indexado")
end
target:setPalette(palette)
local bodyLayer=target.layers[1]
local frameNo=1
local totalRemoved,totalRemovedSmall,largestRemoved=0,0,0
local perAnimation={}
local anyClipped=0

local function nearest_index(p)
  local r,g,b=rgb(p)
  local best,bestD=1,math.huge
  for i=1,28 do
    local c=paletteColors[i]
    local dr,dg,db=r-c[1],g-c[2],b-c[3]
    local d=dr*dr+dg*dg+db*db
    if d<bestD then best,bestD=i,d end
  end
  return best
end
local function is_body_index(v)
  return v>0 and not (v>=18 and v<=20)
end

for _,spec in ipairs(specs) do
  local img=spec.image
  local heights={}
  perAnimation[spec.name]=heights
  for fi=1,spec.count do
    local core0=math.floor((fi-1)*img.width/spec.count)
    local core1=math.floor(fi*img.width/spec.count)-1
    local frame0=math.max(0,core0-SOURCE_MARGIN)
    local frame1=math.min(img.width-1,core1+SOURCE_MARGIN)
    local anchor=spec.anchors[fi]
    local footX,footY,topY,bodyHeight=anchor.footX,anchor.footY,anchor.topY,anchor.height
    -- Shared sheet normalization plus a per-frame head correction for inconsistent poses.
    local frameScale=scale*spec.sheetScale*spec.meanHeadHeight/anchor.headHeight
    local left,top,right,bottom=img.width,img.height,-1,-1
    for y=0,img.height-1 do for x=core0,core1 do
      if alpha(img:getPixel(x,y))>96 then
        left=math.min(left,x); right=math.max(right,x)
        top=math.min(top,y); bottom=math.max(bottom,y)
      end
    end end
    local projected={
      64+math.floor((left-footX)*frameScale+0.5), 64+math.floor((right-footX)*frameScale+0.5),
      88+math.floor((top-footY)*frameScale+0.5), 88+math.floor((bottom-footY)*frameScale+0.5)
    }
    local isClipped=(projected[1]<0 or projected[2]>=W or projected[3]<0 or projected[4]>=H)
    if isClipped then anyClipped=anyClipped+1 end
    local raw={}
    for y=0,H-1 do
      local sy=footY+math.floor((y-FOOT_Y)/frameScale+0.5)
      if sy>=0 and sy<img.height then
        for x=0,W-1 do
          local sx=footX+math.floor((x-PIVOT_X)/frameScale+0.5)
          if sx>=frame0 and sx<=frame1 and sx>=0 and sx<img.width then
            local p=img:getPixel(sx,sy)
            if alpha(p)>96 then raw[y*W+x+1]=nearest_index(p) end
          end
        end
      end
    end
    local visited,components={},{}
    for y=0,H-1 do for x=0,W-1 do
      local start=y*W+x+1
      if raw[start] and not visited[start] then
        local queue={start}; visited[start]=true; local q=1; local pixels={}
        while q<=#queue do
          local k=queue[q]; q=q+1; pixels[#pixels+1]=k
          local px=(k-1)%W; local py=math.floor((k-1)/W)
          for ny=math.max(0,py-1),math.min(H-1,py+1) do
            for nx=math.max(0,px-1),math.min(W-1,px+1) do
              local nk=ny*W+nx+1
              if raw[nk] and not visited[nk] then visited[nk]=true; queue[#queue+1]=nk end
            end
          end
        end
        components[#components+1]=pixels
      end
    end end
    local main=1
    for i=2,#components do if #components[i]>#components[main] then main=i end end
    if #components==0 then error("Quadro vazio: "..spec.name.." "..fi) end
    local keep={}
    for _,k in ipairs(components[main]) do keep[k]=raw[k] end
    for ci,pixels in ipairs(components) do if ci~=main then
      totalRemoved=totalRemoved+1
      if #pixels<20 then totalRemovedSmall=totalRemovedSmall+1 end
      largestRemoved=math.max(largestRemoved,#pixels)
    end end
    local outline={}
    for k in pairs(keep) do
      local x=(k-1)%W; local y=math.floor((k-1)/W)
      for ny=math.max(0,y-1),math.min(H-1,y+1) do
        for nx=math.max(0,x-1),math.min(W-1,x+1) do
          local nk=ny*W+nx+1
          if not keep[nk] then outline[nk]=true end
        end
      end
    end
    local out=Image(W,H,ColorMode.INDEXED)
    local topBody,bottomBody=nil,nil
    for k,v in pairs(keep) do
      local x=(k-1)%W; local y=math.floor((k-1)/W)
      out:drawPixel(x,y,v)
      if is_body_index(v) then topBody=topBody and math.min(topBody,y) or y; bottomBody=bottomBody and math.max(bottomBody,y) or y end
    end
    for k in pairs(outline) do out:drawPixel((k-1)%W,math.floor((k-1)/W),1) end
    if not topBody or not bottomBody then error("Sem pixels de corpo em "..spec.name.." "..fi) end
    heights[#heights+1]=bottomBody-topBody+1
    target:newCel(bodyLayer,target.frames[frameNo],out,Point(0,0))
    log(string.format("%s %d: source_body=%d output_body=%d output_head=%.1fpx components=%d removed=%d projected_bounds=%d,%d,%d,%d",spec.name,fi,bodyHeight,heights[#heights],anchor.headHeight*frameScale,#components,#components-1,projected[1],projected[3],projected[2],projected[4]))
    frameNo=frameNo+1
  end
  spec.source:close()
end
for name,hs in pairs(perAnimation) do
  local lo,hi=math.huge,-math.huge
  for _,h in ipairs(hs) do lo=math.min(lo,h); hi=math.max(hi,h) end
  log(string.format("%s measured body height range=%d-%d px",name,lo,hi))
end
log(string.format("detached islands removed=%d (under 20 px=%d); remaining detached islands=0; largest removed=%d px",totalRemoved,totalRemovedSmall,largestRemoved))
log(string.format("frames with projected content outside 160x96=%d",anyClipped))
target:saveAs(dstPath)
target:close()
local f=io.open(reportPath,"w")
if not f then error("Nao foi possivel escrever relatorio: "..reportPath) end
for _,line in ipairs(report) do f:write(line.."\n") end
f:close()
