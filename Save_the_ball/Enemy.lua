local love = require "love"

function Enemy(level)
  local dice = math.random(1, 4) -- random value to spawn at random locations of the screen
  local _x, _y
  local _radius = 20
-- define the sides based on the dice rolled
  if dice == 1 then
    _x = math.random(_radius, love.graphics.getWidth())
    _y = -_radius * 4
  elseif dice == 2 then
    _x = -_radius * 4
    _y = math.random(_radius, love.graphics.getHeight())
  elseif dice == 3 then
    _x = math.random(_radius, love.graphics.getWidth())
    _y = math.random(_radius, love.graphics.getHeight()) + (_radius * 4)
  else
    _x = math.random(_radius, love.graphics.getWidth()) + (_radius * 4)
    _y = math.random(_radius, love.graphics.getHeight()) + (_radius * 4)
  end
  return {
    level = level or 1, --starting level of the enemy
    radius = _radius,
    x = _x,
    y = _y,
    -- function to check if player touched the enemy
    checkTouched = function(self, player_x, player_y, cursor_radius)
      return math.sqrt((self.x - player_x) ^ 2 + (self.y - player_y) ^ 2) <= cursor_radius * 2
    end,
    
    move = function (self, player_x, player_y) -- move the enemy towards the player
            -- move to in player x pos
      if player_x - self.x > 0 then
        self.x = self.x + self.level
      elseif player_x - self.x < 0 then
        self.x = self.x - self.level
      end
         
            -- move to player y pos
      if player_y - self.y > 0 then
        self.y = self.y + self.level
      elseif player_y - self.y < 0 then
        self.y = self.y - self.level
      end
    end,

    draw = function (self) -- draw enemy
            -- set the color to white
      love.graphics.setColor(1, 0.5, 0.7)
            -- draw a circle (the enemy)
      love.graphics.circle("fill", self.x, self.y, self.radius)

            -- reset the color back to white
      love.graphics.setColor(1, 1, 1)
    end,
  }
end

return Enemy