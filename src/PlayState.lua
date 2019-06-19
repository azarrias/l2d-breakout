PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
  self.paddle = params.paddle
  self.bricks = params.bricks
  self.health = params.health
  self.score = params.score
  self.ball = params.ball
  
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
  
  if love.keyboard.keysPressed['escape'] then
    gStateMachine:change('start')
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
  
  -- if ball goes past the paddle, decrement lives and either game over or serve again
  if self.ball.y >= VIRTUAL_HEIGHT then
    self.health = self.health - 1
    gSounds['hurt']:play()
    
    if self.health == 0 then
      gStateMachine:change('game-over', {
        score = self.score
      })
    else
      gStateMachine:change('serve', {
        paddle = self.paddle,
        bricks = self.bricks,
        health = self.health,
        score = self.score
      })
    end
  end
  
  -- detect ball collision iterating all bricks
  for k, brick in pairs(self.bricks) do
    if brick.inPlay and self.ball:collides(brick) then
      self.score = self.score + 10
      brick:hit()
      
      if (self.ball.x + self.ball.width / 2) < (brick.x + brick.width / 2) then
        shift_ball_x = brick.x - (self.ball.x + self.ball.width)
      else
        shift_ball_x = brick.x + brick.width - self.ball.x
      end
      
      if (self.ball.y + self.ball.height / 2) < (brick.y + brick.height / 2) then
        shift_ball_y = brick.y - (self.ball.y + self.ball.height)
      else
        shift_ball_y = brick.y + brick.height - self.ball.y
      end
      
      -- Zero the shift axis that has the maximum shift (if any)
      if math.abs(shift_ball_y) > math.abs(shift_ball_x) then
        shift_ball_y = 0
      elseif math.abs(shift_ball_x) > math.abs(shift_ball_y) then
        shift_ball_x = 0
      end
      
      self.ball.x = self.ball.x + shift_ball_x
      self.ball.y = self.ball.y + shift_ball_y
      
      if shift_ball_x ~= 0 then
        self.ball.dx = -self.ball.dx
      end
      if shift_ball_y ~= 0 then
        self.ball.dy = -self.ball.dy
      end
      
      -- Scale y velocity to speed up the game
      self.ball.dy = self.ball.dy * 1.02
      -- Only allow colliding with one brick, for corner collisions
      break
    end
  end
end

function PlayState:render()
  self.paddle:render()
  self.ball:render()
  
  for k, brick in pairs(self.bricks) do
    brick:render()
  end
  
  renderScore(self.score)
  renderHealth(self.health)
  
  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("GAME PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
  end
end