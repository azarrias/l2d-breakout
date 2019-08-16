--[[
    GD50
    Breakout Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Creates randomized levels for our Breakout game. Returns a table of
    bricks that the game can render, based on the current level we're at
    in the game.
]]

ROW_PATTERN_SOLID = 1
ROW_PATTERN_ALTERNATE = 2
ROW_PATTERN_NONE = 3

LevelMaker = Class{} 

--[[
    Creates a table of Bricks to be returned to the main game, with different
    possible ways of randomizing rows and columns of bricks. Calculates the
    brick colors and tiers to choose based on the level passed in.
]]
function LevelMaker.createMap(level)
    local MAX_COLS = math.floor(VIRTUAL_WIDTH / BRICK_WIDTH)
    local COL_PADDING = (VIRTUAL_WIDTH % BRICK_WIDTH) / 2
    
    local bricks = {}

    -- randomly choose the number of rows
    local numRows = math.random(1, 5)

    -- randomly choose the number of columns, ensuring that the number is odd
    local numCols = math.random(7, MAX_COLS)
    numCols = numCols % 2 == 0 and numCols + 1 or numCols
    
    -- restrict maximum tier (0-3) and color (3-5) given a level number
    local maxTier = math.min(3, math.floor(level / 5))
    local maxColor = math.min(5, level % 5 + 3)

    -- lay out bricks such that they touch each other and fill the space
    repeat
      for y = 1, numRows do                      -- leave row 0 to display lives and score
        -- randomize pattern for each row
        local rowPattern = math.random(1, 3)
        local colors = {}
        local tiers = {}
        
        colors[1] = math.random(1, maxColor)
        tiers[1] = math.random(0, maxTier)
        
        -- Flag to skip a block for the skip variant
        skipColVariant = math.random(2) == 1 and 
            (rowPattern == ROW_PATTERN_SOLID or rowPattern == ROW_PATTERN_ALTERNATE) and true or false
        skipColFlag = math.random(2) == 1 and true or false
        
        -- Index for color and tier for the alternate and solid patterns
        if rowPattern == ROW_PATTERN_SOLID then
          index = 1
        elseif rowPattern == ROW_PATTERN_ALTERNATE then
          index = math.random(2)
          colors[2] = math.random(1, maxColor)
          tiers[2] = math.random(0, maxTier)
        end

        if rowPattern ~= ROW_PATTERN_NONE then
          for x = 0, numCols - 1 do  
            if not (skipColVariant and skipColFlag) then 
              b = Brick(
                x * BRICK_WIDTH + COL_PADDING  -- x-coordinate
                + (MAX_COLS - numCols) * BRICK_WIDTH / 2, -- left-side padding for when there are fewer than 13 columns
            
                y * BRICK_HEIGHT
              ) 
            
              b.color = colors[index]
              b.tier = tiers[index]
          
              if rowPattern == ROW_PATTERN_ALTERNATE then
                index = index % 2 + 1
              end

              table.insert(bricks, b)
            end
            skipColFlag = not skipColFlag
          end
        end
      end 
    until (#bricks > 0)

    return bricks
end