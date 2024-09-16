// Raycast Camera is a renderer that represents a Map as a pseudo-3D environment
RaycastCamera = class
  
  constructor = function()
    this.Position = new RCVec(-50, -50)
    this.Rotation = 0 // degrees
    
    this.FieldOfView = 60 // degrees
    
    this.NumberOfRays = 50 // default because of screen "resolution"
    this.RayLength = 100 // length of rays
    this.RayHitDetectionStep = 1
    
    this.Map = ""
  end
  
  SetMap = function(mapName)
    this.Map = maps[mapName]
    if this.Map == 0 then print("ERROR! Map with name '"+ mapName +"' doesn't exists!") end
  end
  
//// Draw draws everything that camera sees to screen
  Draw = function()
    local startAngle = this.Rotation - (this.FieldOfView / 2)
    local angleIncrement = this.FieldOfView / this.NumberOfRays
    
    screen.drawMap(this.Map, 0, 0, 80, 80)
    
    for i=1 to this.NumberOfRays
      // calculate current ray
      local ray = new RaycastCameraRay(this.Position, startAngle + i*angleIncrement)
      if ray.Direction >=360 then ray.Direction = ray.Direction - 360 end
      
      // display ray
      // local endX = ray.Origin.X + this.RayLength * cosd(ray.Direction)
      // local endY = ray.Origin.Y + this.RayLength * sind(ray.Direction)
      // screen.drawLine(ray.Origin.X, ray.Origin.Y, endX, endY)
      
      local stepX = 0
      local stepY = 0
      
      if ray.Direction >=0 and ray.Direction < 90 then
        stepX = +1
        stepY = +1
      end
      if ray.Direction >=90 and ray.Direction < 180 then
        stepX = +1
        stepY = -1
      end
      if ray.Direction >=180 and ray.Direction < 270 then
        stepX = -1
        stepY = -1
      end
      if ray.Direction >=270 and ray.Direction < 360 then
        stepX = +1
        stepY = +1
      end
      
      local hit = 0
      local hitCheckLocX = ray.Origin.X
      local hitCheckLocY = ray.Origin.Y
      
      local itterationCount = this.RayLength / this.RayHitDetectionStep
      
      for itterationNum = 1 to itterationCount
        hitCheckLocX += this.RayHitDetectionStep * cosd(ray.Direction)
        hitCheckLocY += this.RayHitDetectionStep * sind(ray.Direction)
        
        local mapX = floor(hitCheckLocX / this.Map.block_width + this.Map.width / 2)
        local mapY = floor(hitCheckLocY / this.Map.block_height + this.Map.height / 2)
        
        local tile = this.Map.get(mapX, mapY)
        
        if tile != 0 then
          screen.drawRect(hitCheckLocX, hitCheckLocY, 0.5, 0.5, "#00FF00")
          hit = tile
          break
        else
          screen.drawRect(hitCheckLocX, hitCheckLocY, 0.5, 0.5, "#FF00FF")
        end
      end
    end
  end
  
end

RaycastCameraRay = class
  // @origin:RCVec
  constructor = function(origin, direction)
    this.Origin = origin
    this.Direction = direction
  end
end