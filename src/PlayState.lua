PlayState = Class{__includes = BaseState}

function PlayState:init()
  self.paddle = Paddle()
  self.ball = Ball(1)
  
  self.ball:reset()
  
  -- give ball random starting velocity
  self.ball.dx = math.random(-200, 200)
  self.ball.dy = math.random(-50, -60)
  
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
  self.ball:update(dt)
  
  if self.ball:collides(self.paddle) then
    -- raise ball above paddle to prevent it from getting stuck
    self.ball.y = self.paddle.y - self.ball.height
    self.ball.dy = -self.ball.dy
    gSounds['paddle-hit']:play()
  end
  
  if love.keyboard.keysPressed['escape'] then
    gStateMachine:change('start')
  end
end

function PlayState:render()
  self.paddle:render()
  self.ball:render()
  
  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("GAME PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
  end
end