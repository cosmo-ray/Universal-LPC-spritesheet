local dir_path = Entity.wrapp(ygGet("lpcs.$path")):to_string() .. "/spritesheets/"
local w_sprite = 64
local h_sprite = 64
local x0 = 0
local y0 = 0
local x_marging = 0
local y_marging = 0
local x_threshold = w_sprite + x_marging
local y_threshold = h_sprite + y_marging
local texture_cache = nil

LPCS_LEFT = 9
LPCS_DOWN = 10
LPCS_RIGHT = 11
LPCS_UP = 8
LPCS_DEAD = 20

local function chacheAndGetImgTexture(path)
   if texture_cache == nil then
      texture_cache = {}
   end

   local t = texture_cache[path]
   if yIsNNil(t) then
      return t
   end
   t = ywTextureNewImg(path);
   ywTextureNormalize(t)
   texture_cache[path] = t;
   return t;
end

function loadCanvas(canvas, texture, pos_sprite_x, pos_sprite_y,
		    x, y)
   pos_sprite_x = yLovePtrToNumber(pos_sprite_x)
   pos_sprite_y = yLovePtrToNumber(pos_sprite_y)
   x = yLovePtrToNumber(x)
   y = yLovePtrToNumber(y)
   local r = Rect.new(pos_sprite_x * x_threshold + x0,
		      pos_sprite_y * y_threshold + y0,
		      w_sprite, h_sprite - 2)
   local ret = ywCanvasNewImgFromTexture(canvas, x, y, texture, r.ent)
   return ret
end

function textureFromCaracter(caracter)
   caracter = Entity.wrapp(caracter)
   local sex = caracter.sex
   local type = caracter.type
   local clothes = caracter.clothes
   local clothes_len = yeLen(clothes)

   if yIsNil(sex) then
      sex = caracter.gender
   end

   if sex:to_string() ~= "female" and sex:to_string() ~= "male" then
      print(sex:to_string(), " isn't a gender")
      return nil
   end
   local base_path = dir_path .. "/body/" .. sex:to_string() ..
      "/" .. type:to_string() .. ".png"
   local texture = ywTextureNewImg(base_path);
   ywTextureNormalize(texture)

   local i = 0
   while i < clothes_len do
      local tmpTexture = chacheAndGetImgTexture(dir_path .. clothes[i]:to_string());
      ywTextureMergeUnsafe(tmpTexture, nil, texture, nil)
      i = i + 1
   end
   local weapon = caracter.sprite_weapon
   if yIsNNil(weapon) then
      local tmpTexture = chacheAndGetImgTexture(dir_path .. "/weapons/" .. weapon:to_string());
      ywTextureMergeUnsafe(tmpTexture, nil, texture, nil)
   end
   return texture
end

function createCaracterHandler(caracter, canvas, father, name)
   name = ylovePtrToString(name)
   local ret = yeCreateArray(father, name)
   caracter = Entity.wrapp(caracter)

   ret = Entity.wrapp(ret)
   ret.char = caracter
   ret.text = textureFromCaracter(caracter)
   -- right hand/male/longsword-attack.png
   local oversize_weapon = caracter.oversize_weapon
   if yIsNNil(oversize_weapon) then
      local oversize_weapon_path = dir_path .. "/weapons/oversize/" .. yeGetString(oversize_weapon)
      ret.oversize_text = ywTextureNewImg(oversize_weapon_path);
   end

   yeDestroy(ret.text)
   ret.wid = canvas
   ret.x = 0
   ret.y = 0
   return ret:cent()
end

function lpcsRemoveCanva(handler)
   handler = Entity.wrapp(handler)

   ywCanvasRemoveObj(handler.wid, handler.oversized_canvas)
   ywCanvasRemoveObj(handler.wid, handler.canvas)
   handler.oversized_canvas = nil
   handler.canvas = nil
end

function lpcsHandlerNullify(handler)
   handler = Entity.wrapp(handler)

   ywCanvasRemoveObj(handler.wid, handler.oversized_canvas)
   ywCanvasRemoveObj(handler.wid, handler.canvas)
   handler.oversized_canvas = nil
   handler.canvas = nil
   handler.char = nil
end

function lpcsHandlerReload(handler)
   handler = Entity.wrapp(handler)
   handler.text = textureFromCaracter(handler.char)
   handlerRefresh(handler)
end

function handlerSetOrigXY(handler, x, y)
   handler = Entity.wrapp(handler)
   handler.x = yLovePtrToNumber(x)
   handler.y = yLovePtrToNumber(y)
end

function handlerPos(handler)
   local canvas = CanvasObj.wrapp(yeGet(handler, "canvas"))

   return canvas:pos().ent:cent()
end

function handlerSize(handler)
   local canvas = CanvasObj.wrapp(yeGet(handler, "canvas"))

   return canvas:size().ent:cent()
end

function handlerRefresh(handler)
   handler = Entity.wrapp(handler)
   local x = 0
   local y = 0
   local wid = Canvas.wrapp(handler.wid)
   if handler.canvas ~= nil then
      local canvas = CanvasObj.wrapp(handler.canvas)
      x = canvas:pos():x()
      y = canvas:pos():y()
      wid:remove(canvas)
   end
   if handler.oversized_canvas ~= nil then
      local canvas = CanvasObj.wrapp(handler.oversized_canvas)
      wid:remove(canvas)
   end
   local h_x = handler.x:to_int()
   handler.canvas = loadCanvas(wid.ent, handler.text, h_x,
			       handler.y:to_int(), x, y)
   print(handler.oversize_text)
   if handler.oversize_text ~= nil and
      yeGetInt(handler.set_oversized_weapon) > 0 then
      local h_y = handler.oversize_weapon_y:to_int()
      local r = Rect.new(h_x * (x_threshold * 3),
			 h_y * (y_threshold * 3),
			 w_sprite * 3, h_sprite * 3)
      handler.oversized_canvas = ywCanvasNewImgFromTexture(wid.ent, x - x_threshold,
							   y - y_threshold,
							   handler.oversize_text, r.ent)
      print(handler.oversized_canvas)
   end
end

function handlerMove(handler, pos)
   handler = Entity.wrapp(handler)
   if handler.canvas == nil then
      handlerRefresh(handler)
   end
   ywCanvasMoveObj(handler.canvas, pos)
end


function handlerMoveXY(handler, x, y)
   local pos = ywPosCreate(yLovePtrToNumber(x),
			   yLovePtrToNumber(y))
   local r = handlerMove(handler, pos)
   yeDestroy(pos)
   return r
end

function handlerSetPos(handler, pos)
   handler = Entity.wrapp(handler)
   if handler.canvas == nil then
      handlerRefresh(handler)
   end
   ywCanvasObjSetPos(handler.canvas, pos)
end

function handlerSetPosXY(handler, x, y)
   local pos = ywPosCreate(yLovePtrToNumber(x),
			   yLovePtrToNumber(y))
   local r = handlerSetPos(handler, pos)
   yeDestroy(pos)
   return r
end

function handlerNextStep(handler)
   handler = Entity.wrapp(handler)
   local linelength = {7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 6, 6, 6, 6, 13, 13, 13, 13, 6}
   if handler.x:to_int() < (linelength[handler.y:to_int()] - 1) then
      handler.x = (handler.x:to_int() + 1)
      return handler.x:to_int() == (linelength[handler.y:to_int()] - 1)
   else
      handler.x = 0
      return false
   end
end

function init_lpcs(mod)
   yeCreateFunction("textureFromCaracter", mod,
		    "textureFromCaracter");
   yeCreateFunction("loadCanvas", mod, "loadCanvas");
   yeCreateFunction("handlerSetOrigXY", mod, "handlerSetOrigXY");
   yeCreateFunction("handlerSetPos", mod, "handlerSetPos")
   yeCreateFunction("handlerMove", mod, "handlerMove");
   yeCreateFunction("createCaracterHandler", mod, "createCaracterHandler")
   yeCreateFunction("handlerRefresh", mod, "handlerRefresh")
   yeCreateFunction("lpcsHandlerReload", mod, "handlerReload")
   yeCreateFunction("lpcsHandlerNullify", mod, "handlerNullify")
   yeCreateFunction(lpcsRemoveCanva, mod, "handlerRemoveCanva")
   yeCreateInt(w_sprite, mod, "w_sprite")
   yeCreateInt(h_sprite, mod, "h_sprite")
   yeCreateInt(x_threshold, mod, "x_threshold")
   yeCreateInt(y_threshold, mod, "y_threshold")

   yeCreateInt(LPCS_LEFT, mod, "LEFT")
   yeCreateInt(LPCS_DOWN, mod, "DOWN")
   yeCreateInt(LPCS_RIGHT, mod, "RIGHT")
   yeCreateInt(LPCS_UP, mod, "UP")
   yeCreateInt(LPCS_DEAD, mod, "DEAD")

   ygRegistreFunc(6, "loadCanvas", "ylpcsLoasCanvas")
   ygRegistreFunc(3, "handlerSetOrigXY", "ylpcsHandlerSetOrigXY")
   ygRegistreFunc(3, "handlerPos", "ylpcsHandePos")
   ygRegistreFunc(1, "handlerSize", "ylpcsHandlerSize")
   ygRegistreFunc(1, "handlerPos", "ylpcsHandlerPos")
   ygRegistreFunc(1, "handlerRefresh", "ylpcsHandlerRefresh")
   ygRegistreFunc(2, "handlerMove", "ylpcsHandlerMove")
   ygRegistreFunc(3, "handlerMoveXY", "ylpcsHandlerMoveXY")
   ygRegistreFunc(2, "handlerSetPos", "ylpcsHandlerSetPos")
   ygRegistreFunc(3, "handlerSetPosXY", "ylpcsHandlerSetPosXY")
   ygRegistreFunc(1, "textureFromCaracter", "ylpcsTextureFromCaracter")
   ygRegistreFunc(4, "createCaracterHandler", "ylpcsCreateHandler")
   ygRegistreFunc(1, "handlerNextStep", "ylpcsHandlerNextStep")
   ygRegistreFunc(1, "lpcsRemoveCanva", "ylpcsRemoveCanvas")
   ygRegistreFunc(1, "lpcsHandlerNullify", "ylpcsHandlerNullify")
end
