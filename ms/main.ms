Camera = 0

init = function()
  Camera = new RaycastCamera()
  Camera.SetMap("testmap")
end

update = function()
  if keyboard.LEFT then
    Camera.Rotation += 1
  end
  
  if keyboard.RIGHT then
    Camera.Rotation -= 1
  end
  
  if keyboard.UP then
    Camera.Position.X += 0.2 * cosd(Camera.Rotation)
    Camera.Position.Y += 0.2 * sind(Camera.Rotation)
  end
  
  if keyboard.DOWN then
    Camera.Position.X -= 0.2 * cosd(Camera.Rotation)
    Camera.Position.Y -= 0.2 * sind(Camera.Rotation)
  end
end

draw = function()
  screen.clear()
  Camera.Draw()
  // system.pause()
end