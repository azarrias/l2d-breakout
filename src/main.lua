push = require 'lib.push'
Class = require 'lib.class'
require 'StateMachine'
require 'BaseState'
require 'StartState'

MOBILE_OS = love.system.getOS() == 'Android' or love.system.getOS() == 'OS X'
GAME_TITLE = 'Breakout'
WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 432, 243

function love.load()
  -- use nearest-neighbor (point) filtering on upscaling and downscaling to prevent blurring of text and 
  -- graphics instead of the bilinear filter that is applied by default 
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.window.setTitle(GAME_TITLE)
  math.randomseed(os.time())
  
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = MOBILE_OS,
    resizable = not MOBILE_OS
  })

  gTextures = {
    ['background'] = love.graphics.newImage('graphics/background.png')
  }
  
  gBackgroundWidth, gBackgroundHeight = gTextures['background']:getDimensions()

  gStateMachine = StateMachine {
    ['start'] = function() return StartState() end
  }
  gStateMachine:change('start')
  
  love.keyboard.keysPressed = {}
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.update(dt)
  gStateMachine:update(dt)
  love.keyboard.keysPressed = {}
end

-- Callback that processes key strokes just once
-- Does not account for keys being held down
function love.keypressed(key)
  love.keyboard.keysPressed[key] = true
end

function love.draw()
  push:apply('start')
  love.graphics.draw(gTextures['background'],
    0, 0, -- draw at 0, 0
    0,    -- no rotation
    VIRTUAL_WIDTH / (gBackgroundWidth - 1), VIRTUAL_HEIGHT / (gBackgroundHeight - 1))
  gStateMachine:render()
  push:apply('end')
end