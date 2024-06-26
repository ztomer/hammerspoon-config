local module = {}
module.__index = module

--
-- Metadata
--
module.name = 'Windows'
module.version = '1.0'
module.author = "{ ken }"
module.homepage = "https://github.com/kenbankspeng/hammerspoon-config"
module.license = 'MIT - https://opensource.org/licenses/MIT'

-- size(w,h) is relative to point(x,y)
-- unit rect: { x, y, w, h } where w and h <= 1
-- rect: { x, y, w, h } where w or h > 1

local inc = 0.1
local minW = 0.3
local minH = 0.3
local centerXY = 0.2

local function move(how)
  local function has(item)
    return string.find(how, item)
  end

  local win = hs.window.focusedWindow()
  local rect = win:screen():toUnitRect(win:frame())
  if not rect then return end
  local x, y, w, h = rect.x, rect.y, rect.w, rect.h

  if has('up') then
    y = math.max(y - inc, 0)
  elseif has('down') then
    if y + h < 1 then
      y = math.min(y + inc, 1 - h)
    else
      y = 1 - h
    end
  elseif has('left') then
    x = math.max(x - inc, 0)
  elseif has('right') then
    if x + w < 1 then
      x = math.min(x + inc, 1 - w)
    else
      x = 1 - w
    end
  end
  win:move({ x, y, w, h })
end

local function stretchOrShrink(how)
  local function has(item)
    return string.find(how, item)
  end

  local win = hs.window.focusedWindow()
  local rect = win:screen():toUnitRect(win:frame())
  if not rect then return end
  local x, y, w, h = rect.x, rect.y, rect.w, rect.h

  if has('stretch') then
    if has('upper') then -- upper edge up
      if y > 0 then
        y = math.max(y - inc, 0)
        h = math.min(h + inc, 1 - y)
      end
    elseif has('left') then -- left edge to the left
      if x > 0 then
        x = math.max(x - inc, 0)
        w = math.min(w + inc, 1 - x)
      end
    elseif has('right') then -- right edge to the right
      if x + w < 1 then w = math.min(w + inc, 1 - x) end
    elseif has('lower') then -- lower edge down
      if y + h < 1 then h = math.min(h + inc, 1 - y) end
    end
  elseif has('shrink') then
    if has('lower') then     -- lower edge up
      if h > minH then h = math.max(h - inc, minH) end
    elseif has('left') then  -- left edge to the right
      if w > minW then w = math.max(w - inc, minW) end
    elseif has('upper') then -- upper edge down
      if h > minH then
        y = math.min(y + inc, 1 - minH)
        h = math.max(h - inc, minH)
      end
    elseif has('right') then -- right edge to the left
      if w > minW then
        w = math.max(w - inc, minW)
        x = math.min(x + inc, 1 - minW)
      end
    end
  end
  win:move({ x, y, w, h })
end


local function scale(how)
  local function has(item)
    return string.find(how, item)
  end

  local win = hs.window.focusedWindow()
  local rect = win:screen():toUnitRect(win:frame())
  if not rect then return end
  local x, y, w, h = rect.x, rect.y, rect.w, rect.h
  local scaleInc = inc / 2

  if has('center') then
    x = centerXY
    y = centerXY
    w = 1 - 2 * x
    h = 1 - 2 * y
  elseif has('bigger') then
    if x > 0 then x = math.max(x - scaleInc, 0) end             -- left
    if x + w < 1 then w = math.min(w + 2 * scaleInc, 1 - x) end -- right
    if y > 0 then y = math.max(y - scaleInc, 0) end             -- upper
    if y + h < 1 then h = math.min(h + 2 * scaleInc, 1 - y) end -- lower
  elseif has('smaller') then
    if w > minW then w = math.max(w - 2 * scaleInc, minW) end   -- right
    if h > minH then h = math.max(h - 2 * scaleInc, minH) end   -- lower
    if w > minW then x = math.min(x + scaleInc, 1 - minW) end   -- left
    if h > minH then y = math.min(y + scaleInc, 1 - minH) end   -- upper
  end
  win:move({ x, y, w, h })
end

function module.winMoveScreen(how)
  local win = hs.window.focusedWindow()
  if how == "left" then
    win:moveOneScreenWest()
  elseif how == "right" then
    win:moveOneScreenEast()
  end
end

function module.wmAction(how)
  local win = hs.window.focusedWindow()
  local actions = {
    move = move,
    stretch = stretchOrShrink,
    shrink = stretchOrShrink,
    scale = scale,
    max = function(_) win:maximize() end,
    ["left half"] = function(_) win:move({ 0, 0, 0.5, 1 }) end,
    ["right half"] = function(_) win:move({ 0.5, 0, 0.5, 1 }) end,
  }

  for key, action in pairs(actions) do
    if string.find(how, key) then
      action(how)
      return
    end
  end
end

return module
