EnterHighScoreState = Class{__includes = BaseState}

-- table to hold the initials (65 is ASCII code for A)
local chars = {
  [1] = 65,
  [2] = 65,
  [3] = 65
}

local highlightedChar = 1

function EnterHighScoreState:enter(params)
  self.highScores = params.highScores
  self.score = params.score
  self.scoreIndex = params.scoreIndex
end

function EnterHighScoreState:update(dt)
  if love.keyboard.keysPressed['enter'] or love.keyboard.keysPressed['return'] then
    -- update scores table
    local name = string.char(chars[1]) .. string.char(chars[2]) .. string.char(chars[3])
    
    -- go backwards through the high scores table until this score, shifting scores
    for i=10, self.scoreIndex, -1 do
      self.highScores[i + 1] = {
        name = self.highScores[i].name,
        score = self.highScores[i].score
      }
    end
    
    self.highScores[self.scoreIndex].name = name
    self.highScores[self.scoreIndex].score = self.score
    
    -- write scores to file
    local scoresStr = ''
    
    for i = 1, 10 do
      scoresStr = scoresStr .. self.highScores[i].name .. '\n'
      scoresStr = scoresStr .. tostring(self.highScores[i].scores) .. '\n'
    end
    
    love.filesystem.write('breakout.lst', scoresStr)
    
    gStateMachine:change('highscores', {
      highScores = self.highScores
    })
  end
  
  -- scroll through character slots
  if love.keyboard.keysPressed['left'] and highlightedChar > 1 then 
    highlightedChar = highlightedChar - 1
    gSounds['select']:play()
  elseif love.keyboard.keysPressed['right'] and highlightedChar < 3 then
    highlightedChar = highlightedChar + 1
    gSounds['select']:play()
  end
  
  -- scroll through characters
  if love.keyboard.keysPressed['up'] then
    chars[highlightedChar] = chars[highlightedChar] + 1
    if chars[highlightedChar] > 90 then
      chars[highlighedChar] = 65
    end
  elseif love.keyboard.keysPressed['down'] then
    chars[highlightedChar] = chars[highlightedChar] - 1
    if chars[highlightedChar] < 65 then
      chars[highlightedChar] = 90
    end
  end
end

function EnterHighScoreState:render()
  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf('Your score: ' .. tostring(self.score), 0, 30,
    VIRTUAL_WIDTH, 'center')

  love.graphics.setFont(gFonts['large'])
    
  -- render all three characters of the name
  if highlightedChar == 1 then
    setColor(103, 255, 255, 255)
  end
  love.graphics.print(string.char(chars[1]), VIRTUAL_WIDTH / 2 - 28, VIRTUAL_HEIGHT / 2)
  setColor(255, 255, 255, 255)

  if highlightedChar == 2 then
    setColor(103, 255, 255, 255)
  end
  love.graphics.print(string.char(chars[2]), VIRTUAL_WIDTH / 2 - 6, VIRTUAL_HEIGHT / 2)
  setColor(255, 255, 255, 255)

  if highlightedChar == 3 then
    love.graphics.setColor(103, 255, 255, 255)
  end
  love.graphics.print(string.char(chars[3]), VIRTUAL_WIDTH / 2 + 20, VIRTUAL_HEIGHT / 2)
  love.graphics.setColor(255, 255, 255, 255)
   
  love.graphics.setFont(gFonts['small'])
  love.graphics.printf('Press Enter to confirm!', 0, VIRTUAL_HEIGHT - 18,
    VIRTUAL_WIDTH, 'center')
end
  
  