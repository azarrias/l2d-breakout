PaddleSelectState = Class{__includes = BaseState}

function PaddleSelectState:enter(params)
  self.highScores = params.highScores
end

function PaddleSelectState:init()
  self.highlightedPaddle = 1
end

function PaddleSelectState:update(dt)
  if love.keyboard.keysPressed['left'] then
    if self.highlightedPaddle == 1 then
      gSounds['no-select']:play()
    else
      gSounds['select']:play()
      self.highlightedPaddle = self.highlightedPaddle - 1
    end
  elseif love.keyboard.keysPressed['right'] then
    if self.highlightedPaddle == 4 then
      gSounds['no-select']:play()
    else
      gSounds['select']:play()
      self.highlightedPaddle = self.highlightedPaddle + 1
    end
  end
  
  if love.keyboard.keysPressed['enter'] or love.keyboard.keysPressed['return'] then
    gSounds['confirm']:play()
    gStateMachine:change('serve', {
      paddle = Paddle(self.highlightedPaddle),
      bricks = LevelMaker.createMap(1),
      health = 3,
      score = 0,
      level = 1,
      highScores = self.highScores
    })
  end
  
  if love.keyboard.keysPressed['escape'] then
    gStateMachine:change('start', {
      highScores = self.highScores
    })
  end
end

function PaddleSelectState:render()
  -- instructions
  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf("Select your paddle with left and right!", 0, VIRTUAL_HEIGHT / 4,
    VIRTUAL_WIDTH, 'center')
  love.graphics.setFont(gFonts['small'])
  love.graphics.printf("(Press Enter to continue!)", 0, VIRTUAL_HEIGHT / 3,
    VIRTUAL_WIDTH, 'center')
        
  -- left arrow; should render normally if we're higher than 1, else
  -- in a shadowy form to let us know we're as far left as we can go
  if self.currentPaddle == 1 then
    -- tint; give it a dark gray with half opacity
    love.graphics.setColor(40, 40, 40, 128)
  end
    
  love.graphics.draw(gTextures['arrows'], gFrames['arrows'][1], VIRTUAL_WIDTH / 4 - 24,
    VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
   
  -- reset drawing color to full white for proper rendering
  love.graphics.setColor(255, 255, 255, 255)

  -- right arrow; should render normally if we're less than 4, else
  -- in a shadowy form to let us know we're as far right as we can go
  if self.currentPaddle == 4 then
    -- tint; give it a dark gray with half opacity
    love.graphics.setColor(40, 40, 40, 128)
  end
    
  love.graphics.draw(gTextures['arrows'], gFrames['arrows'][2], VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4,
    VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
    
  -- reset drawing color to full white for proper rendering
  love.graphics.setColor(255, 255, 255, 255)

  -- draw the paddle itself, based on which we have selected
  love.graphics.draw(gTextures['main'], gFrames['paddles'][2 + 4 * (self.highlightedPaddle - 1)],
    VIRTUAL_WIDTH / 2 - 32, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
end
