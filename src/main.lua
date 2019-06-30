push = require 'lib.push'
Class = require 'lib.class'

require 'StateMachine'
require 'BaseState'
require 'StartState'
require 'PlayState'
require 'ServeState'
require 'GameOverState'
require 'VictoryState'
require 'HighScoreState'

require 'Paddle'
require 'Ball'
require 'Brick'

require 'Util'
require 'LevelMaker'

MOBILE_OS = love.system.getOS() == 'Android' or love.system.getOS() == 'OS X'
GAME_TITLE = 'Breakout'
WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 432, 243

BRICK_WIDTH, BRICK_HEIGHT = 32, 16

gColors = {
  aquamarine = { 127, 255, 212 },
  red = { 217, 87, 99 },
  green = { 106, 190, 47 },
  blue = { 99, 155, 255 },
  yellow = { 255, 255, 0 },
  white = { 255, 255, 255 },
  black = { 0, 0, 0 },
  purple = { 215, 123, 186 },
  gold = { 251, 242, 54 }
}

V11 = love._version_major > 0 or love._version_major == 0 and love._version_minor >= 11
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
  if V11 then
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
  if V11 then
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
    ['main'] = love.graphics.newImage('graphics/breakout.png'),
    ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
    ['particle'] = love.graphics.newImage('graphics/particle.png')
  }
  
  gFrames = {
    ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
    ['balls'] = GenerateQuadsBalls(gTextures['main']),
    ['bricks'] = GenerateQuadsBricks(gTextures['main']),
    ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9)
  }
  
  gSounds = {
    ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
    ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
    ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),
    ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
    ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav', 'static'),
    ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav', 'static'),
    ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
    ['victory'] = love.audio.newSource('sounds/victory.wav', 'static')
  }
  
  gBackgroundWidth, gBackgroundHeight = gTextures['background']:getDimensions()

  gStateMachine = StateMachine {
    ['start'] = function() return StartState() end,
    ['serve'] = function() return ServeState() end,
    ['play'] = function() return PlayState() end,
    ['game-over'] = function() return GameOverState() end,
    ['victory'] = function() return VictoryState() end,
    ['highscores'] = function() return HighScoreState() end
  }
  gStateMachine:change('start', {
    highScores = loadHighScores()
  })
  
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

--[[
    Renders hearts based on how much health the player has. First renders
    full hearts, then empty hearts for however much health we're missing.
]]
function renderHealth(health)
    -- starting x position of our health rendering
    local healthX = VIRTUAL_WIDTH * 0.75
    
    -- render health left
    for i = 1, health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 4)
        healthX = healthX + 11
    end

    -- render missing health
    for i = 1, 3 - health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 4)
        healthX = healthX + 11
    end
end

-- Renders the score at the top right, left-side padding for the score number
function renderScore(score)
    love.graphics.setFont(gFonts['small'])
    love.graphics.print('Score:', VIRTUAL_WIDTH - 60, 5)
    love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, 'right')
end

-- Loads highscores from a file in LOVE2D's default save directory
function loadHighScores()
  love.filesystem.setIdentity('breakout')
  
  if V11 then 
    fileMissing = not love.filesystem.getInfo('breakout.lst')
  else 
    fileMissing = not love.filesystem.exists('breakout.lst')
  end
  
  if fileMissing then
    local scores = ''
    for i = 10, 1, -1 do
      scores = scores .. 'BKO\n'
      scores = scores .. tostring(i * 1000) .. '\n'
    end
    
    love.filesystem.write('breakout.lst', scores)
  end
  
  local name = true
  local currentName = nil
  local counter = 1
    
  local scores = {}
  for i = 1, 10 do
    scores[i] = {
      name, score = nil, nil
    }
  end
    
  for line in love.filesystem.lines('breakout.lst') do
    if name then
      scores[counter].name = string.sub(line, 1, 3)
    else
      scores[counter].score = tonumber(line)
      counter = counter + 1
    end
      
    -- toggle name flag
    name = not name
  end
  
  return scores
end
  