// "Mouse lock lib" by JmeJuniper

// init some variables
mouse.dx = 0
mouse.dy = 0
mouse.locked = 0

// js
system.javascript("
  // get the canvas
  var canvas = document.querySelector('canvas');
  
  // callback functions
  function updatePosition(mse) {
    global.mouse.dx = mse.movementX;
    // negative movementY because of microstudio's coordinate grid
    global.mouse.dy = -mse.movementY;
  }
  function toggleMove() {
    // handle lock toggling
    if (document.pointerLockElement == canvas) {
      global.mouse.locked = 1
      canvas.addEventListener('mousemove', updatePosition);
    } else {
      global.mouse.locked = 0
      canvas.removeEventListener('mousemove', updatePosition);
    }
  }
  
  // lock mouse pointer
  canvas.onclick = function() {
    canvas.requestPointerLock();
  };
  document.addEventListener('pointerlockchange', toggleMove);
")

// stop dx and dy when mouse stops
every 20 milliseconds do
  mouse.dx = 0
  mouse.dy = 0
end