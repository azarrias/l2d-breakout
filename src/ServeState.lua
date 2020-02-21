ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
  self.paddle = params.paddle
  self.bricks = params.bricks
  self.health = params.health
  self.score = params.score
  self.level = params.level
  self.highScores = params.highScores
  
  self.ball = Ball(1)
end

function ServeState:update(dt)
  self.paddle:update(dt)
  self.ball.x = self.paddle.x + (self.paddle.width / 2) - (self.ball.width / 2)
  self.ball.y = self.paddle.y - self.ball.height
  
  if love.keyboard.keysPressed['space'] then
    -- pass in all needed state variables into the PlayState
    gStateMachine:change('play', {
      paddle = self.paddle,
      bricks = self.bricks,
      health = self.health,
      score = self.score,
      ball = self.ball,
      level = self.level,
      highScores = self.highScores
    })
  end
  
  if love.keyboard.keysPressed['escape'] then
    gStateMachine:change('start', {
      highScores = self.highScores
    })
  end
end

function ServeState:render()
  self.paddle:render()
  self.ball:render()
  
  for k, brick in pairs(self.bricks) do
    brick:render()
  end
end