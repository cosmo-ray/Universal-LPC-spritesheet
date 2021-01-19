local dir_path = Entity.wrapp(ygGet("lpcs.$path")):to_string() .. "/spritesheets/"
local w_sprite = 42
local h_sprite = 56
local x0 = 10
local y0 = 10
local x_marging = 22
local y_marging = 8
local x_threshold = w_sprite + x_marging
local y_threshold = h_sprite + y_marging

LPCS_LEFT = 9
LPCS_DOWN = 10
LPCS_RIGHT = 11
LPCS_UP = 8
LPCS_DEAD = 20

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

   if sex:to_string() ~= "female" and sex:to_string() ~= "male" then
      print(sex:to_string(), " isn't a gender")
      return nil
   end
   local base_path = dir_path .. "/body/" .. sex:to_string() ..
      "/" .. type:to_string() .. ".png"
   local texture = ywTextureNewImg(base_path);

   local i = 0
   while i < clothes_len do
      local tmpTexture = ywTextureNewImg(dir_path .. clothes[i]:to_string());
      ywTextureMerge(tmpTexture, nil, texture, nil)
      yeDestroy(tmpTexture)
      i = i + 1
   end
   return texture
end

function createCaracterHandler(caracter, canvas, father, name)
   name = ylovePtrToString(name)
   local ret = yeCreateArray(father, name)

   ret = Entity.wrapp(ret)
   ret.char = caracter
   ret.text = textureFromCaracter(caracter)
   yeDestroy(ret.text)
   ret.wid = canvas
   ret.x = 0
   ret.y = 0
   return ret:cent()
end

function lpcsHandlerNullify(handler)
   handler = Entity.wrapp(handler)

   ywCanvasRemoveObj(handler.wid, handler.canvas)
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
   handler.canvas = loadCanvas(wid.ent, handler.text, handler.x:to_int(),
				handler.y:to_int(), x, y)
end

function handlerMove(handler, pos)
   handler = Entity.wrapp(handler)
   if handler.canvas == nil then
      handlerRefresh(handler)
   end
   ywCanvasMoveObj(handler.canvas, pos)
end

function handlerSetPos(handler, pos)
   handler = Entity.wrapp(handler)
   if handler.canvas == nil then
      handlerRefresh(handler)
   end
   ywCanvasObjSetPos(handler.canvas, pos)
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
   ygRegistreFunc(1, "handlerRefresh", "ylpcsHandlerRefresh")
   ygRegistreFunc(2, "handlerMove", "ylpcsHandlerMove")
   ygRegistreFunc(2, "handlerSetPos", "ylpcsHandlerSetPos")
   ygRegistreFunc(1, "textureFromCaracter", "ylpcsTextureFromCaracter")
   ygRegistreFunc(4, "createCaracterHandler", "ylpcsCreateHandler")
   ygRegistreFunc(1, "handlerNextStep", "ylpcsHandlerNextStep")
end
