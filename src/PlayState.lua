PlayState = Class{__includes = BaseState}

function PlayState:init()
  self.paddle = Paddle()
  self.paused = false
end

function PlayState:update(dt)
  if self.paused then
    if love.keyboard.keysPressed['space'] then
      self.paused = false
      gSounds['pause']:play()
    else
      return
    end
  elseif love.keyboard.keysPressed['space'] then
    self.paused = true
    gSounds['pause']:play()
    return
  end
  
  self.paddle:update(dt)
  
  if love.keyboard.keysPressed['escape'] then
    gStateMachine:change('start')
  end
end

function PlayState:render()
  self.paddle:render()
  
  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("GAME PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
  end
end