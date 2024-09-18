Camera = 0

init = function()
  Camera = new RaycastCamera()
  Camera.SetMap("testmap")
end

update = function()
  if keyboard.LEFT then
    Camera.Rotation += 0.5
  end
  
  if keyboard.RIGHT then
    Camera.Rotation -= 0.5
  end
  
  if keyboard.UP then
    Camera.Position.X += 0.2 * cosd(Camera.Rotation)
    Camera.Position.Y += 0.2 * sind(Camera.Rotation)
  end
  
  if keyboard.DOWN then
    Camera.Position.X -= 0.2 * cosd(Camera.Rotation)
    Camera.Position.Y -= 0.2 * sind(Camera.Rotation)
  end
  
  if keyboard.press.H then
    if Camera.DebugView == 1 then Camera.DebugView = 0
      else Camera.DebugView = 1 end
  end
  
  if keyboard.press.F then
    if Camera.FisheyeCorrection == 1 then Camera.FisheyeCorrection = 0
      else Camera.FisheyeCorrection = 1 end
  end
end

draw = function()
  screen.clear()
  
  Camera.Draw()
  //system.pause()
  
  screen.drawText("Press H to toggle Debug View", -95, 95, 5, "#FFFFFF")
  screen.drawText("Press F to toggle Fisheye correction", -88, 90, 5, "#FFFFFF")
  screen.drawText("FPS: " + system.fps, 100, 95, 5, "#FFFFFF")
end