local module = {}
module.__index = module

-- Metadata
module.name = 'Modal'
module.version = '1.0'
module.author = "{ ken }"
module.homepage = "https://github.com/kenbankspeng/hammerspoon-config"
module.license = 'MIT - https://opensource.org/licenses/MIT'

-- spoon dependencies
local overlay = spoon.Overlay

-- local requires
local group = dofile(hs.spoons.resourcePath("group.lua"))
local timer = dofile(hs.spoons.resourcePath("timer.lua"))

local modal = nil
local registeredKeys = {}
local isActive = false

local tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp }, function(event)
    return timer.handleEvent(event, registeredKeys, isActive)
end)

local function registerKey(t, item)
    if not hs.fnutils.contains(t, item) then
        table.insert(t, item)
    end
end

local function toggle()
    overlay.toggle()
    if isActive then
        if modal then modal:exit() end
        tap:stop()
        isActive = false
    else
        if modal then modal:enter() end
        tap:start()
        isActive = true
    end
end

function module.action(hotkey, callback, options)
    if not modal then return end
    local mods = hotkey[1]
    local key = hotkey[2]
    registerKey(registeredKeys, key)

    options = options or {}
    local msg = options.msg

    local groupId = options.group
    local actionType = options.type

    if groupId and not actionType then
        group.addAction(groupId, { callback, msg })
    end

    if options.interval then
        timer.addBinding(key, { options.interval, callback })
    end

    modal:bind(mods, key, function()
        -- callback wrapper entrypoint
        if actionType == "next" then
            local nextCallback, nextMsg = group.handleNext(groupId, options.loop)
            if nextCallback then nextCallback() end
            msg = nextMsg
        elseif actionType == "prev" then
            local prevCallback, prevMsg = group.handlePrev(groupId, options.loop)
            if prevCallback then prevCallback() end
            msg = prevMsg
        elseif callback then
            callback()
        end
        -- alert.send(msg) or overlay:set({ msg = msg or 'none' })
    end)
end

function module:init()
    modal = hs.hotkey.modal.new()
end

function module:bindHotkeys(mapping)
    if not mapping or not mapping.toggle then return end
    registerKey(registeredKeys, mapping.toggle[2])
    local actions = { toggle = toggle }
    hs.spoons.bindHotkeysToSpec(actions, mapping)
end

return module
