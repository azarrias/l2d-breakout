StartState = Class{__includes = BaseState}

-- 1 - Start
-- 2 - High Scores
local highlightedOption = 1

function StartState:enter(params)
  self.highScores = params.highScores
end

function StartState:update(dt)
  -- toggle highlighted option if we press up or down arrow keys
  if love.keyboard.keysPressed['up'] or love.keyboard.keysPressed['down'] then
    highlightedOption = highlightedOption == 1 and 2 or 1
    gSounds['paddle-hit']:play()
  end
  
  if love.keyboard.keysPressed['enter'] or love.keyboard.keysPressed['return'] then
    gSounds['confirm']:play()
    
    if highlightedOption == 1 then
      gStateMachine:change('paddle-select', {
        highScores = self.highScores
      })
    elseif highlightedOption == 2 then
      gStateMachine:change('highscores', {
        highScores = self.highScores
      })
    end
  end
  
  -- exit if esc is pressed
  if love.keyboard.keysPressed['escape'] then
    love.event.quit()
  end
end

function StartState:render()
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf("BREAKOUT", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
    
  -- instructions
  love.graphics.setFont(gFonts['medium'])

  -- if we're highlighting 1, render that option yellow
  if highlightedOption == 1 then
    setColor(gColors.aquamarine)
  end
  love.graphics.printf("START", 0, VIRTUAL_HEIGHT / 2 + 70, VIRTUAL_WIDTH, 'center')

  -- reset the color
  setColor(gColors.white)

  -- render option 2 yellow if we're highlighting that one
  if highlightedOption == 2 then
    setColor(gColors.aquamarine)
  end
  love.graphics.printf("HIGH SCORES", 0, VIRTUAL_HEIGHT / 2 + 90, VIRTUAL_WIDTH, 'center')

  -- reset the color
  setColor(gColors.white)
end
