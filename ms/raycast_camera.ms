// Raycast Camera is a renderer that represents a Map as a pseudo-3D environment
RaycastCamera = class
  
  constructor = function()
    this.Position = new RCVec(-20, 0)
    this.Rotation = 330 // degrees
    
    this.FieldOfView = 60 // degrees
    
    this.NumberOfRays = 100 // default because of screen "resolution"
    this.RayLength = 100 // length of rays
    this.RayHitDetectionStep = 0.5
    
    this.WallHeight = 2000
    
    this.Map = ""
    
    this.DebugView = 0
    this.FisheyeCorrection = 1
    
    this.Billboards = []
  end
  
  SetMap = function(mapName)
    this.Map = maps[mapName]
    if this.Map == 0 then print("ERROR! Map with name '"+ mapName +"' doesn't exists!") end
  end
  
  AddBillboard = function(spriteName, x, y, width, height)
    local b = new RCBillboard()
    
    b.SpriteName = spriteName
    b.X = x
    b.Y = y
    b.Width = width
    b.Radius = width/2
    b.RadiusSquared = b.Radius * b.Radius
    b.Height = height
    
    this.Billboards.push(b)
  end
  
//// Draw draws everything that camera sees to screen
  Draw = function()
    local startAngle = this.Rotation - (this.FieldOfView / 2)
    local angleIncrement = this.FieldOfView / this.NumberOfRays
    
    if DebugView == 1 then 
      screen.drawMap(this.Map, 0, 0, 80, 80) 
    end
    
    local hits_map = []
    local hits_billboards = []
    
    local textureU = -1
    local leftEdge = 0
    local side = -1
    local hitPlace = -1
    
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
        
        // check billboards
        
        for b = 0 to this.Billboards.length - 1
          
          if this.Billboards[b].RayHandled.contains(i) == 1 then
            // this ray already registered this billboard
            continue
          end
          
          local dx = hitCheckLocX - this.Billboards[b].X
          local dy = hitCheckLocY - this.Billboards[b].Y
          
          if dx * dx + dy * dy <= this.Billboards[b].RadiusSquared then
            
            distance = this.Position.Distance(this.Billboards[b].X, this.Billboards[b].Y) + this.Billboards[b].Width
            
            local billboardSpliceX = hitCheckLocX + this.Billboards[b].Radius * cosd(ray.Direction)
            local billboardSpliceY = hitCheckLocY + this.Billboards[b].Radius * sind(ray.Direction)
            
            local spliceDist = RCVec.StaticDistance(this.Billboards[b].X, this.Billboards[b].Y, billboardSpliceX, billboardSpliceY)
            
            local spliceReminder = this.Billboards[b].Radius - spliceDist
            
            local ux = billboardSpliceX - this.Position.X
            local uy = billboardSpliceY - this.Position.Y
            local vx = this.Billboards[b].X - this.Position.X
            local vy = this.Billboards[b].Y - this.Position.Y
            
            local cross = ux * vy - uy * vx
            
            if cross <= 0 then
              textureU = spliceReminder / this.Billboards[b].Width
            else
              textureU = 1 - spliceReminder / this.Billboards[b].Width
            end
            
            hits_billboards.push(new RCHitInfo(
                                      this.Billboards[b].SpriteName, 
                                      distance,
                                      0,
                                      textureU,
                                      i))
            
            this.Billboards[b].RayHandled.push(i)
          end
        end
        
        // check map
        
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
          
          leftEdge = (mapX - this.Map.width / 2) * this.Map.block_width
          hitPlace = abs(hitCheckLocX - leftEdge)
          if hitPlace <= this.RayHitDetectionStep or
             hitPlace > this.Map.block_width - this.RayHitDetectionStep then
            side = 1
          else
            side = 0
          end
          
          if side == 0 then
            textureU = mapXwithFraction - mapX
          else
            textureU = mapYwithFraction - mapY
          end
          
          hits_map.push(new RCHitInfo(tile, 
                                  distance,
                                  side,
                                  textureU,
                                  i))
                                
          if DebugView == 1 then screen.drawRect(hitCheckLocX, hitCheckLocY, 0.5, 0.5, "#00FF00") end
          
          break // when you hit a map tile, don't trance further away
        else
          if DebugView == 1 then screen.drawRect(hitCheckLocX, hitCheckLocY, 0.5, 0.5, "#FF00FF") end
        end
      end
    end
    
    if this.DebugView == 1 then
      for b = 0 to this.Billboards.length - 1
        screen.drawSprite(this.Billboards[b].SpriteName, this.Billboards[b].X, this.Billboards[b].Y, this.Billboards[b].Width, this.Billboards[b].Height)
      end
    end
    
    // sort billboards by longest distance (draw those further away first)
    hits_billboards.sortList(RCHitInfo.StaticCompare)
      
    // all data gathered. Can start drawing now
  
    if this.DebugView == 0 then
      local width = screen.width / this.NumberOfRays
      local halfScreen = screen.width / 2
      
      local currentX = 0
      local wallHeight = 0
      local sprite = 0
      local partX = 0
      
      // draw map
      if hits_map.length > 0 then
        for m = 0 to (hits_map.length - 1)
          currentX = m * width
          wallHeight = this.WallHeight / hits_map[m].Distance
          
          sprite = sprites[hits_map[m].Tile]
          partX = round(sprite.width * hits_map[m].TextureU)
          if partX >= sprite.width then partX = sprite.width - 1 end
          
          // print("### " + x)
          // print("spriteName: " + hits_map[x].Tile)
          // print("sprite.width: " + sprite.width)
          // print("hits_map[x].TextureU: " + hits_map[x].TextureU)
          // print("partX: " + partX)
          // print("screen.width: " + screen.width)
          // print("x: " + (currentX - halfScreen))
          // print("width: " + width)
          // print("wallHeight: " + wallHeight)
          
          screen.drawSpritePart(hits_map[m].Tile,
                                partX, 0, 1, sprite.height,
                                -currentX + halfScreen, 0, width, wallHeight)
        end
      end
      
      // draw billboards
      if hits_billboards.length > 0 then
        for b = 0 to (hits_billboards.length - 1)
          currentX = hits_billboards[b].RayNumber * width
          wallHeight = (this.WallHeight * 1.1) / hits_billboards[b].Distance
          sprite = sprites[hits_billboards[b].Tile]
          partX = round(sprite.width * hits_billboards[b].TextureU)
          if partX >= sprite.width then partX = sprite.width - 1 end
          
          // print("### " + b)
          // print("spriteName: " + hits_billboards[b].Tile)
          // print("sprite.width: " + sprite.width)
          // print("hits_billboards[x].TextureU: " + hits_billboards[b].TextureU)
          // print("partX: " + partX)
          // print("screen.width: " + screen.width)
          // print("x: " + (currentX - halfScreen))
          // print("width: " + width)
          // print("wallHeight: " + wallHeight)
          
          screen.drawSpritePart(hits_billboards[b].Tile,
                                partX, 0, 1, sprite.height,
                                -currentX + halfScreen, 0, width, wallHeight)
        end
      end
    end
    
    // clear billboards
    this.Billboards = []
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
  
  StaticDistance = function(firstX, firstY, secondX, secondY)
    local deltaX = secondX - firstX
    local deltaY = secondY - firstY
    
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
  constructor = function(tile, distance, side, textureU, rayNumber)
    this.Tile = tile
    this.Distance = distance
    this.Side = side
    this.TextureU = textureU
    this.RayNumber = rayNumber
  end
  
  StaticCompare = function(hi1,hi2)
  return hi2.Distance - hi1.Distance
end
end

RCBillboard = class
  constructor = function()
    this.SpriteName = ""
    this.X = 0
    this.Y = 0
    this.Width = 8
    this.Height = 8
    this.Radius = 4
    this.RadiusSquared = 16
    this.RayHandled = []
  end
end