Paddle = Class{}

-- paddle movement speed
local PADDLE_SPEED = 200

function Paddle:init(skin)
  -- initialize to the horizontal middle a little above the bottom
  self.x = VIRTUAL_WIDTH / 2 - 32
  self.y = VIRTUAL_HEIGHT - 32
  -- starts with no velocity
  self.dx = 0
  
  self.width = 64
  self.height = 16
  
  -- offset into the gPaddleSkins table (to manage its color)
  self.skin = skin
  
  -- size goes from 1 (smallest) to 4 (largest)
  self.size = 2
end

function Paddle:update(dt)
  -- input
  if love.keyboard.isDown('left') then
    self.dx = -PADDLE_SPEED
  elseif love.keyboard.isDown('right') then
    self.dx = PADDLE_SPEED
  else
    self.dx = 0
  end
  
  -- prevent from going out of bounds
  if self.dx < 0 then
    self.x = math.max(0, self.x + self.dx * dt)
  else
    self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
  end
end

function Paddle:render()
  love.graphics.draw(gTextures['main'], --Texture
    gFrames['paddles'][self.size + 4 * (self.skin - 1)], --Quad (4 paddle quads per color)
    self.x, self.y) --Position
end
