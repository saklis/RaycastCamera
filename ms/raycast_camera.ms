// Raycast Camera is a renderer that represents a Map as a pseudo-3D environment
RaycastCamera = class
  
  constructor = function()
    this.Position = new RCVec(-27, 0)
    this.Rotation = 0 // degrees
    
    this.FieldOfView = 60 // degrees
    
    this.NumberOfRays = 100 // default because of screen "resolution"
    this.RayLength = 200 // length of rays
    this.RayHitDetectionStep = 0.25
    
    this.WallHeight = 2000
    
    this.Map = ""
    
    this.DebugView = 1
    this.FisheyeCorrection = 1
  end
  
  SetMap = function(mapName)
    this.Map = maps[mapName]
    if this.Map == 0 then print("ERROR! Map with name '"+ mapName +"' doesn't exists!") end
  end
  
//// Draw draws everything that camera sees to screen
  Draw = function()
    local startAngle = this.Rotation - (this.FieldOfView / 2)
    local angleIncrement = this.FieldOfView / this.NumberOfRays
    
    if DebugView == 1 then screen.drawMap(this.Map, 0, 0, 80, 80) end
    
    local hits = []
    
    for i=1 to this.NumberOfRays
      // calculate current ray
      local ray = new RaycastCameraRay(this.Position, startAngle + i*angleIncrement)
      if ray.Direction >=360 then ray.Direction = ray.Direction - 360 end
      
      local hitCheckLocX = ray.Origin.X
      local hitCheckLocY = ray.Origin.Y
      
      local itterationCount = this.RayLength / this.RayHitDetectionStep
      
      for itterationNum = 1 to itterationCount
        hitCheckLocX += this.RayHitDetectionStep * cosd(ray.Direction)
        hitCheckLocY += this.RayHitDetectionStep * sind(ray.Direction)
        
        local distance = this.Position.Distance(hitCheckLocX, hitCheckLocY)
        if this.FisheyeCorrection == 1 then
          distance = distance * cosd(ray.Direction - this.Rotation)
        end
        
        local hitPointX = hitCheckLocX / this.Map.block_width
        local hitPointY = hitCheckLocY / this.Map.block_height
        
        local mapXwithFraction = hitPointX + this.Map.width / 2
        local mapYwithFraction = hitPointY + this.Map.height / 2
        
        local mapX = floor(mapXwithFraction)
        local mapY = floor(mapYwithFraction)
        
        local tile = this.Map.get(mapX, mapY)
        
        if tile != 0 then
          // check wall alignment
          // 0 = horisontal edge on the map
          // 1 = vertical edge on the map
          local leftEdge = (mapX - this.Map.width / 2) * this.Map.block_width
          
          local side = -1
          if abs(hitCheckLocX - leftEdge) <= this.RayHitDetectionStep then
            side = 1
          else
            side = 0
          end
          
          local textureU = -1
          if side == 0 then
            textureU = mapXwithFraction - mapX
          else
            textureU = mapYwithFraction - mapY
          end
          
          hits.push(new RCHitInfo(tile, 
                                  distance,
                                  side,
                                  textureU))
                                
          if DebugView == 1 then screen.drawRect(hitCheckLocX, hitCheckLocY, 0.5, 0.5, "#00FF00") end
          
          break
        else
          if DebugView == 1 then screen.drawRect(hitCheckLocX, hitCheckLocY, 0.5, 0.5, "#FF00FF") end
        end
      end
    end
      
    // all data gathered. Can start drawing now
    if this.DebugView == 0 then
      local width = screen.width / hits.length
      local halfScreen = screen.width / 2
      
      //print("hits.length: " + hits.length)
      for x = 0 to (hits.length - 1)
        local currentX = x * width
        local wallHeight = this.WallHeight / hits[x].Distance
        
        local sprite = sprites[hits[x].Tile]
        local partX = round(sprite.width * hits[x].TextureU)
        
        // print("### " + x)
        // print("spriteName: " + hits[x].Tile)
        // print("sprite.width: " + sprite.width)
        // print("hits[x].TextureU: " + hits[x].TextureU)
        // print("partX: " + partX)
        // print("screen.width: " + screen.width)
        // print("x: " + (currentX - halfScreen))
        // print("width: " + width)
        // print("wallHeight: " + wallHeight)
        
        screen.drawSpritePart(hits[x].Tile,
                              partX, 0, 1, 7,
                              currentX - halfScreen, 0, width, wallHeight)
      end
    end
  end
  
end

RCVec = class
  constructor = function(x = 0, y = 0)
    this.X = x
    this.Y = y
  end
  
  Distance = function(otherX, otherY)
    local deltaX = otherX - this.X
    local deltaY = otherY - this.Y
    
    return sqrt(deltaX * deltaX + deltaY * deltaY)
  end
end

RaycastCameraRay = class
  // @origin:RCVec
  constructor = function(origin, direction)
    this.Origin = origin
    this.Direction = direction
  end
end

RCHitInfo = class
  constructor = function(tile, distance, side, textureU)
    this.Tile = tile
    this.Distance = distance
    this.Side = side
    this.TextureU = textureU
  end
end