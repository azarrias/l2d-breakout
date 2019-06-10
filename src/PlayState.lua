PlayState = Class{__includes = BaseState}

function PlayState:init()
  self.paddle = Paddle()
  self.ball = Ball(1)
  
  self.ball:reset()
  
  -- give ball random starting velocity
  self.ball.dx = math.random(-200, 200)
  self.ball.dy = math.random(-50, -60)
  
  self.paused = false
  
  self.bricks = LevelMaker.createMap()
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
    
    -- influence the ball's dx based on where it hits the paddle
    -- and how the paddle is moving
    if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
      self.ball.dx = -50 - (8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
    elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
      self.ball.dx = 50 + (8 * (self.ball.x - self.paddle.x - self.paddle.width / 2))
    end
    
    gSounds['paddle-hit']:play()
  end
  
  -- detect collision across all bricks with the ball
  for k, brick in pairs(self.bricks) do
    if brick.inPlay and self.ball:collides(brick) then
      brick:hit()
      
      -- 2 is a small margin to prioritize the y collision
      -- for the corner collisions to work better
      if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
        self.ball.dx = -self.ball.dx
        self.ball.x = brick.x - self.ball.width
      elseif self.ball.x + self.ball.width - 2 > brick.x and self.ball.dx < 0 then
        self.ball.dx = -self.ball.dx
        self.ball.x = brick.x + brick.width
      elseif self.ball.y < brick.y then
        self.ball.dy = -self.ball.dy
        self.ball.y = brick.y - self.ball.height
      else
        self.ball.dy = -self.ball.dy
        self.ball.y = brick.y + brick.height
      end

    end
  end
  
  if love.keyboard.keysPressed['escape'] then
    gStateMachine:change('start')
  end
end

function PlayState:render()
  self.paddle:render()
  self.ball:render()
  
  for k, brick in pairs(self.bricks) do
    brick:render()
  end
  
  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("GAME PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
  end
end