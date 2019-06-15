ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
  self.paddle = params.paddle
  self.bricks = params.bricks
  self.health = params.health
  self.score = params.score
  
  self.ball = Ball(1)
end

function ServeState:update(dt)
  self.paddle:update(dt)
  self.ball.x = self.paddle.x + (self.paddle.width / 2) - (self.ball.width / 2)
  self.ball.y = self.paddle.y - self.ball.height
  
  if love.keyboard.keysPressed['enter'] or love.keyboard.keysPressed['return'] then
    -- pass in all needed state variables into the PlayState
    gStateMachine:change('play', {
      paddle = self.paddle,
      bricks = self.bricks,
      health = self.health,
      score = self.score,
      ball = self.ball
    })
  end
  
  if love.keyboard.keysPressed['escape'] then
    gStateMachine:change('start')
  end
end

function ServeState:render()
  self.paddle:render()
  self.ball:render()
  
  for k, brick in pairs(self.bricks) do
    brick:render()
  end
end