Camera = 0

init = function()
  Camera = new RaycastCamera()
  Camera.SetMap("testmap")
end

update = function()
  // MOVEMENT
  if keyboard.LEFT then
    Camera.Position.X += 0.075 * cosd(Camera.Rotation + 90)
    Camera.Position.Y += 0.075 * sind(Camera.Rotation + 90)
  end
  
  if keyboard.RIGHT then
    Camera.Position.X += 0.075 * cosd(Camera.Rotation - 90)
    Camera.Position.Y += 0.075 * sind(Camera.Rotation - 90)
  end
  
  if keyboard.UP then
    Camera.Position.X += 0.2 * cosd(Camera.Rotation)
    Camera.Position.Y += 0.2 * sind(Camera.Rotation)
  end
  
  if keyboard.DOWN then
    Camera.Position.X -= 0.2 * cosd(Camera.Rotation)
    Camera.Position.Y -= 0.2 * sind(Camera.Rotation)
  end
  
  // MOUSE
  if mouse.dx != 0 then
    Camera.Rotation -= mouse.dx * 0.2
  end
  
  // DEBUG VIEW
  if keyboard.press.H then
    if Camera.DebugView == 1 then Camera.DebugView = 0
      else Camera.DebugView = 1 end
  end
  
  // FISHEYE CORRECTION
  if keyboard.press.F then
    if Camera.FisheyeCorrection == 1 then Camera.FisheyeCorrection = 0
      else Camera.FisheyeCorrection = 1 end
  end
  
  // FIELD OF VIEW
  if keyboard.press.O then
    Camera.FieldOfView -= 1
  end
  if keyboard.press.P then
    Camera.FieldOfView += 1
  end
end

draw = function()
  screen.clear()
  
  // add billboards - all things that should be drawn, beside the map - enemies, items, special effects
  Camera.AddBillboard("monster", 10, 0, 8, 8)
  Camera.AddBillboard("monster", 20, 0, 8, 8)
  
  // draw everything
  Camera.Draw()
  //system.pause()
  
  screen.drawText("Press H to toggle Debug View", -95, 95, 5, "#FFFFFF")
  screen.drawText("Press F to toggle Fisheye correction", -88, 90, 5, "#FFFFFF")
  screen.drawText("Press O/P to change Field of View. Current: " + Camera.FieldOfView, -77.5, 85, 5, "#FFFFFF")
  screen.drawText("FPS: " + system.fps, 100, 95, 5, "#FFFFFF")
end