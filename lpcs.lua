local dir_path = YIRL_MODULES_PATH .. "Universal-LPC-spritesheet/"
local w_sprite = 36
local h_sprite = 56
local x0 = 14
local y0 = 10
local x_marging = 28
local y_marging = 8
local x_threshold = w_sprite + x_marging
local y_threshold = h_sprite + y_marging

function loadCanvas(canvas, texture, pos_sprite_x, pos_sprite_y,
		    x, y)
   pos_sprite_x = yLovePtrToNumber(pos_sprite_x)
   pos_sprite_y = yLovePtrToNumber(pos_sprite_y)
   x = yLovePtrToNumber(x)
   y = yLovePtrToNumber(y)
   local r = Rect.new(pos_sprite_x * x_threshold + x0,
		      pos_sprite_y * y_threshold + y0,
		      w_sprite, h_sprite)
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
   print("gender: ", sex:to_string(), "race: ", type:to_string())
   local base_path = dir_path .. "/body/" .. sex:to_string() ..
      "/" .. type:to_string() .. ".png"
   print("base sprite:", base_path)
   local texture = ywTextureNewImg(base_path);

   local i = 0
   while i < clothes_len do
      local tmpTexture = ywTextureNewImg(dir_path .. clothes[i]:to_string());
      print(i, clothes[i], tmpTexture)
      print(ywTextureMerge(tmpTexture, nil, texture, nil))
      yeDestroy(tmpTexture)
      i = i + 1
   end
   return texture
end

function createCaracterHandeler(caracter, canvas, father, name)
   name = ylovePtrToString(name)
   local ret = yeCreateArray(father, name)

   ret = Entity.wrapp(ret)
   ret.char = caracter
   ret.text = textureFromCaracter(caracter)
   ret.wid = canvas
   ret.x = 0
   ret.y = 0
   return ret:cent()
end

function handelerSetOrigXY(handeler, x, y)
   handeler = Entity.wrapp(handeler)
   handeler.x = x
   handeler.y = y
end

function handelerRefresh(handeler)
   handeler = Entity.wrapp(handeler)
   local x = 0
   local y = 0
   local wid = Canvas.wrapp(handeler.wid)
   if handeler.canvas ~= nil then
      local canvas = CanvasObj.wrapp(handeler.canvas)
      x = canvas:pos():x()
      y = canvas:pos():y()
      wid:remove(canvas)
   end
   handeler.canvass = loadCanvas(wid.ent:cent(), handeler.text, handeler.x,
				handeler.y, x, y)
end

function handelerMove(handeler, pos)
   handeler = Entity.wrapp(handeler)
   ywCanvasMoveObj(handeler.canvas, pos)
end

function init_lpcs(mod)
   yeCreateFunction("textureFromCaracter", mod,
		    "textureFromCaracter");
   yeCreateFunction("loadCanvas", mod, "loadCanvas");
   yeCreateFunction("handelerSetOrigXY", mod, "handelerSetOrigXY");
   yeCreateFunction("handelerMove", mod, "handelerMove");
   yeCreateFunction("createCaracterHandeler", mod, "createCaracterHandeler")
   yeCreateFunction("handelerRefresh", mod, "handelerRefresh")

   ygRegistreFunc(6, "loadCanvas", "ylpcsLoasCanvas")
   ygRegistreFunc(3, "handelerSetOrigXY", "ylpcsHandelerSetOrigXY")
   ygRegistreFunc(1, "handelerRefresh", "ylpcsHandelerRefresh")
   ygRegistreFunc(2, "handelerMove", "ylpcsHandelerMove")
   ygRegistreFunc(1, "textureFromCaracter", "ylpcsTextureFromCaracter")
   ygRegistreFunc(4 "createCaracterHandeler", "ylpcsCreateHandeler")
end
