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
ROW_PATTERN_SKIP = 3
ROW_PATTERN_NONE = 4

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
        local rowPattern = math.random(1, 4)
        local colors = {}
        local tiers = {}
        
        colors[1] = math.random(1, maxColor)
        tiers[1] = math.random(0, maxTier)
        
        -- Flag to skip a block for the skip pattern
        skipColFlag = math.random(2) == 1 and true or false
        
        if rowPattern == ROW_PATTERN_ALTERNATE then
          colors[2] = math.random(1, maxColor)
          tiers[2] = math.random(0, maxTier)
        elseif rowPattern == ROW_PATTERN_NONE then
          goto continue
        end
        
        for x = 0, numCols - 1 do        
          if rowPattern == ROW_PATTERN_SKIP and skipColFlag then
            skipColFlag = not skipColFlag
            goto continue
          else
            skipColFlag = not skipColFlag
          end
          
          b = Brick(
            x * BRICK_WIDTH + COL_PADDING  -- x-coordinate
            + (MAX_COLS - numCols) * BRICK_WIDTH / 2, -- left-side padding for when there are fewer than 13 columns
            
            y * BRICK_HEIGHT
          ) 
            
          b.color = colors[x % #colors + 1]
          b.tier = tiers[x % #tiers + 1]

          table.insert(bricks, b)
          
          -- Use goto as a workaround for lua not having the continue statement
          ::continue::
        end
        ::continue::
      end 
    until (#bricks > 0)

    return bricks
end