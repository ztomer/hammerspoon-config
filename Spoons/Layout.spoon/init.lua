local module = {}
module.__index = module

--
-- Metadata
--
module.name = 'Layout'
module.version = '1.0'
module.author = "{ ken }"
module.homepage = "https://github.com/kenbankspeng/hammerspoon-config"
module.license = 'MIT - https://opensource.org/licenses/MIT'

local groups = {}
local groupLayoutIndexes = {}
local initializedGroups = {}

local function nextLayoutIndex(group, direction)
  if not groups[group] then
    return
  end

  if direction == "forward" then
    groupLayoutIndexes[group] = (groupLayoutIndexes[group] % #groups[group]) + 1
  else
    groupLayoutIndexes[group] = (groupLayoutIndexes[group] - 2 + #groups[group]) % #groups[group] + 1
  end
end

local function activateOrLaunchApp(bundleID)
  local app = hs.application.get(bundleID)
  if not app then
    hs.application.launchOrFocusByBundleID(bundleID)
  elseif app:isHidden() then
    app:unhide()
  else
    app:activate()
  end
end

local function ensureAppIsActive(bundleID)
  local app = hs.application.get(bundleID)
  if not app or app:isHidden() or not app:mainWindow() then
    hs.application.launchOrFocusByBundleID(bundleID)
  end
end

local function applyGroupLayout(group)
  if not groups[group] then
    return
  end

  local rects = groups[group][groupLayoutIndexes[group]]
  local layout = {}
  local pendingApps = #rects
  local fullScreenApp = nil

  local function checkWindowAndApplyLayout()
    if pendingApps == 0 then
      hs.layout.apply(layout)

      -- Bring the full-screen app to the front if there is one
      if fullScreenApp then
        local application = hs.application.get(fullScreenApp.bundleID)
        if application then
          local mainWindow = application:mainWindow()
          if mainWindow then
            mainWindow:raise()
            mainWindow:focus()
          end
        end
      end
    end
  end

  for _, app in ipairs(rects) do
    ensureAppIsActive(app.bundleID)

    local function checkWindow()
      local application = hs.application.get(app.bundleID)
      if application then
        local mainWindow = application:mainWindow()
        if mainWindow then
          if app.command == "minimize" then
            mainWindow:minimize()
          else
            mainWindow:unminimize()
            mainWindow:focus()
            local entry = { app.bundleID, nil, "Built-in Retina Display", app.rect }
            table.insert(layout, entry)

            -- Check if this app should be full screen (1, 1 size)
            if app.rect and app.rect[3] == 1 and app.rect[4] == 1 then
              fullScreenApp = app
            end
          end
          pendingApps = pendingApps - 1
          checkWindowAndApplyLayout()
        else
          hs.timer.doAfter(0.1, checkWindow)
        end
      else
        pendingApps = pendingApps - 1
        checkWindowAndApplyLayout()
      end
    end

    -- Check window after a short delay to ensure it's ready
    hs.timer.doAfter(0.2, checkWindow)
  end
end

function module.layoutAction(group, direction)
  if not initializedGroups[group] then
    for _, layout in ipairs(groups[group]) do
      for _, app in ipairs(layout) do
        activateOrLaunchApp(app.bundleID)
      end
    end
    initializedGroups[group] = true
  end

  nextLayoutIndex(group, direction)
  applyGroupLayout(group)
end

function module.registerGroup(group, layouts, _)
  groups[group] = layouts
  groupLayoutIndexes[group] = 1
end

return module
