local dir_path = YIRL_MODULES_PATH .. "Universal-LPC-spritesheet/"
local w_sprite = 60
local h_sprite = 56
local x0 = 14
local y0 = 10
local x_threshold = w_sprite + x0
local y_threshold = h_sprite + y0

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
   print("ret:", ret)
   return ret
end

function textureFromCaracter(caracter)
   caracter = Entity.wrapp(caracter)
   local sex = caracter.sex
   local type = caracter.type

   if sex:to_string() ~= "female" and sex:to_string() ~= "male" then
      print(sex:to_string(), " isn't a gender")
      return nil
   end
   print("gender: ", sex:to_string(), "race: ", type:to_string())
   local base_path = dir_path .. "/body/" .. sex:to_string() ..
      "/" .. type:to_string() .. ".png"
   print("base sprite:", base_path)
   local texture = ywTextureNewImg(base_path);
   return texture
end

function init_lpcs(mod)
   yeCreateFunction("textureFromCaracter", mod,
		    "textureFromCaracter");
   yeCreateFunction("loadCanvas", mod, "loadCanvas");
   print("hi !!")
end
