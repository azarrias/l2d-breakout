push = require 'lib.push'
Class = require 'lib.class'

require 'StateMachine'
require 'BaseState'
require 'StartState'
require 'PlayState'

require 'Paddle'
require 'Ball'

require 'Util'

MOBILE_OS = love.system.getOS() == 'Android' or love.system.getOS() == 'OS X'
GAME_TITLE = 'Breakout'
WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 432, 243

gColors = {
  aquamarine = { 127, 255, 212 },
  red = { 255, 0, 0 },
  green = { 0, 255, 0 },
  blue = { 0, 0, 255 },
  yellow = { 255, 255, 0 },
  white = { 255, 255, 255 },
  black = { 0, 0, 0 }
}

local NEW_COLOR_RANGE = love._version_major > 0 or love._version_major == 0 and love._version_minor >= 11
local gBackgroundWidth, gBackgroundHeight

-- Wrapper functions to handle differences across love2d versions
setColor = function(r, g, b, a)
  if type(r) == 'table' and not (g or b or a) then
    r, g, b, a = unpack(r)
  end
  if not r or not g or not b or 
    not tonumber(r) or not tonumber(g) or not tonumber(b) 
    or a and not tonumber(a) then
    error("bad argument to 'setColor' (number expected)")
  end
  a = a or 255
  if NEW_COLOR_RANGE then
    love.graphics.setColor(r/255, g/255, b/255, a/255)
  else
    love.graphics.setColor(r, g, b, a)
  end
end

clear = function(r, g, b, a, clearstencil, cleardepth)
  if type(r) == 'table' and not (g or b or a) then
    r, g, b, a = unpack(r)
  end
  if not r or not g or not b or 
    not tonumber(r) or not tonumber(g) or not tonumber(b) 
    or a and not tonumber(a) then
    error("bad argument to 'clear' (number expected)")
  end
  a, clearstencil, cleardepth = a or 255, clearstencil or true, cleardepth or true
  if NEW_COLOR_RANGE then
    love.graphics.clear(r/255, g/255, b/255, a/255, clearstencil, cleardepth)
  else
    love.graphics.clear(r, g, b, a)
  end
end

function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
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

  gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
  }

  gTextures = {
    ['background'] = love.graphics.newImage('graphics/background.png'),
    ['main'] = love.graphics.newImage('graphics/breakout.png')
  }
  
  gFrames = {
    ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
    ['balls'] = GenerateQuadsBalls(gTextures['main'])
  }
  
  gSounds = {
    ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav'),
    ['confirm'] = love.audio.newSource('sounds/confirm.wav'),
    ['pause'] = love.audio.newSource('sounds/pause.wav'),
    ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav')
  }
  
  gBackgroundWidth, gBackgroundHeight = gTextures['background']:getDimensions()

  gStateMachine = StateMachine {
    ['start'] = function() return StartState() end,
    ['play'] = function() return PlayState() end
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
  
  displayFPS(5, 5)
  
  push:apply('end')
end

function displayFPS(x, y)
    -- simple FPS display across all states
    love.graphics.setFont(gFonts['small'])
    setColor(gColors.green)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), x, y)
end
