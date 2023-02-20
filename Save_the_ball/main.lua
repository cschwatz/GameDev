-- import other files
local love = require "love"
local enemy = require "Enemy"
local button = require "Button"

math.randomseed(os.time())
-- table for the states of the game
local game = {
    difficulty = 1, -- to set the game difficulty
    state = {
        menu = true,
        paused = false,
        running = false, -- the enemy should only move if running is true
        ended = false
    },
  points = 0,
  levels = {15, 30, 60, 120} -- number of points that increase the difficulty of the enemies
}

local player = { 
  radius = 20,
  x = 30,
  y = 30  
}

local buttons = { -- table for all the buttons (such as menu)
  menu_state = {},
  ended_state = {}
}

local fonts = {
  medium = {
    font = love.graphics.newFont(16),
    size = 16
  },
  large = {
    font = love.graphics.newFont(24),
    size = 24
  },
  massive = {
    font = love.graphics.newFont(60),
    size = 60
  }
}

local enemies = {} -- table for enemies created

local function changeGameState(state) -- function to more easily change the game state inside other functions
  game.state["menu"] = state == "menu"
  game.state["paused"] = state == "paused"
  game.state["running"] = state == "running"
  game.state["ended"] = state == "ended"
end

local function startNewGame() -- function to create a new game and reset counters
  changeGameState("running")
  game.points = 0

  enemies = {
    enemy(1)
  }
end

function love.mousepressed(x, y, button, istouch, presses) -- function to check mouseclick
  if not game.state["running"] then -- check if not in-game
    if button == 1 then -- if left click
      if game.state["menu"] then
        for index in pairs(buttons.menu_state) do -- check if its one of the buttons created
          buttons.menu_state[index]:checkPressed(x, y, player.radius) -- function to see if click is inside button area
        end
      elseif game.state["ended"] then
        for index in pairs(buttons.ended_state) do -- check if its one of the buttons created
          buttons.ended_state[index]:checkPressed(x, y, player.radius) -- function to see if click is inside button area
        end
      end
    end
  end
end

function love.load()
  -- gives a title to the popup window
  love.window.setTitle("Save the Ball")
  -- hides mouse cursor
  love.mouse.setVisible(false)
  -- create buttons on the main menu screen
  buttons.menu_state.play_game = button("Play Game", startNewGame, nil, 120, 40)
  buttons.menu_state.settings = button("Settings", nil, nil, 120, 40)
  buttons.menu_state.exit_game = button("Exit Game", love.event.quit, nil, 120, 50)
  -- create buttons on end screen
  buttons.ended_state.replay_game = button("Replay", startNewGame, nil, 100, 50)
  buttons.ended_state.menu = button("Menu", changeGameState, "menu", 100, 50)
  buttons.ended_state.exit_game = button("Quit", love.event.quit, nil, 100, 50)
end

function love.update(dt)
  -- gets the position of the mouse on screen and passes to x and y
  player.x, player.y = love.mouse.getPosition()
  if game.state["running"] then
    for i = 1, #enemies do -- so we can update all the enemies
      if not enemies[i]:checkTouched(player.x, player.y, player.radius) then
        enemies[i]:move(player.x, player.y) -- move the enemies towards the player
        for j = 1, #game.levels do -- increases difficulty as time passes
          if math.floor(game.points) == game.levels[j] then
            table.insert(enemies, 1, enemy(game.difficulty * (j + 1))) -- creates a new enemy with higher difficulty
            game.points = game.points + 1 -- do this to avoid creating multiple enemies since 1 frame happens multiple times across the span of 1s
          end
        end
      else
        changeGameState("ended") -- if game is over
      end
    end
    game.points = game.points + dt -- increase points as time passes
  end
end

function love.draw()
  love.graphics.setFont(fonts.medium.font)
  -- print FPS counter: fps funcc, font size, x, y, stretching
  love.graphics.printf("FPS: " .. love.timer.getFPS(), 
    fonts.medium.font,
    10, 
    (love.graphics.getHeight() - 50), 
    love.graphics.getWidth()
  )
  
  if game.state["running"] then
    love.graphics.printf("Points: " .. math.floor(game.points), fonts.large.font, 0, 10, love.graphics.getWidth(), "center") -- print points on the screen
    for i = 1, #enemies do -- draw all the enemies
        enemies[i]:draw() -- every enemy has its own draw function
    end

    love.graphics.circle("fill", player.x, player.y, player.radius)
  elseif game.state["menu"] then -- draw the menu buttons
    buttons.menu_state.play_game:draw(10, 20, 17, 10)
    buttons.menu_state.settings:draw(10, 70, 17, 10)
    buttons.menu_state.exit_game:draw(10, 120, 17, 10)
  elseif game.state["ended"] then -- draw the menu buttons
    love.graphics.setFont(fonts.large.font)
    buttons.ended_state.replay_game:draw(love.graphics.getWidth() / 2.25, love.graphics.getHeight() / 1.8, 10, 10)
    buttons.ended_state.menu:draw(love.graphics.getWidth() / 2.25, love.graphics.getHeight() / 1.53, 17, 10)
    buttons.ended_state.exit_game:draw(love.graphics.getWidth() / 2.25, love.graphics.getHeight() / 1.33, 22, 10)
  love.graphics.printf(math.floor(game.points), fonts.massive.font, 0, love.graphics.getHeight() / 2 - fonts.massive.size, love.graphics.getWidth(), "center")
  end
  
  if not game.state["running"] then -- decrease the size of the cursor
    love.graphics.circle("fill", player.x, player.y, player.radius / 2)
  end
end