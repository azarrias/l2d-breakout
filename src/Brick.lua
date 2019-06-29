Brick = Class{}

brickColors = {
  [1] = 'blue',
  [2] = 'green',
  [3] = 'red',
  [4] = 'purple',
  [5] = 'gold'
}

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
  
  -- particle system belonging to the brick, will emit on hit
  self.particles = love.graphics.newParticleSystem(gTextures['particle'], 64)
  
  -- determine particle system behavior
  self.particles:setParticleLifetime(0.5, 1)
  self.particles:setLinearAcceleration(-15, 0, 15, 80)
  
  -- just to keep this compatible
  if V11 then 
    self.particles:setEmissionArea('normal', 10, 10)
  else 
    self.particles:setAreaSpread('normal', 10, 10)
  end
  
end

function Brick:hit()
  color = gColors[brickColors[self.color]]
  if V11 then
    self.particles:setColors(color[1]/255, color[2]/255, color[3]/255, 55 * (self.tier + 1)/255, color[1]/255, color[2]/255, color[3]/255, 0)
  else 
    self.particles:setColors(color[1], color[2], color[3], 55 * (self.tier + 1), color[1], color[2], color[3], 0)
  end
  self.particles:emit(64)
  
  -- sound on hit
  gSounds['brick-hit-2']:stop()
  gSounds['brick-hit-2']:play()
  
  -- Go to lower brick class
  if self.color == 1 then
    if self.tier > 0 then
      self.tier = self.tier - 1
      self.color = 5
    else
      self.inPlay = false
    end
  else
    self.color = self.color - 1
  end
  
  if not self.inPlay then
    gSounds['brick-hit-1']:stop()
    gSounds['brick-hit-1']:play()
  end  
end

function Brick:update(dt)
  self.particles:update(dt)
end

function Brick:render()
  if self.inPlay then
    love.graphics.draw(gTextures['main'], -- Texture
      -- multiply color by 4 (because there are 4 tiers or bricks per color)
      -- and add the tier value to lookup the quad in the table
      -- color goes from 1 to 5 and tier goes from 0 to 3
      gFrames['bricks'][1 + ((self.color - 1) * 4) + self.tier], -- Quad
      self.x, self.y) -- Position
  end
end

function Brick:renderParticles()
    love.graphics.draw(self.particles, self.x + 16, self.y + 8)
end