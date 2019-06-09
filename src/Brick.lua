Brick = Class{}

function Brick:init(x, y)
  self.tier = 0
  self.color = 1
  
  self.x = x
  self.y = y
  self.width = 32
  self.height = 16
  
  -- used to determine whether this brick should be rendered
  -- this way we don't need to manage bricks deallocation
  self.inPlay = true
end

function Brick:hit()
  gSounds['brick-hit-2']:play()
  self.inPlay = false
end

function Brick:render()
  if self.inPlay then
    love.graphics.draw(gTextures['main'], -- Texture
      -- multiply color by 4 (because there are 4 tiers or bricks per color)
      -- and add the tier value to lookup the quad in the table
      gFrames['bricks'][1 + ((self.color - 1) * 4) + self.tier], -- Quad
      self.x, self.y) -- Position
  end
end
