-- HammerSpoon script entry point

local Lib = require('Lib')

-- pre-installed manually
Lib.loader.loadSpoons({
  'Console',
  'ReloadConfiguration',
  'EmmyLua', --vscode autocomplete
  'CircleClock',
  'Calendar',
  'Overlay',
  'Modal',
  'AppLauncher',
  'Windows',
  'Layout',
})

local partial = hs.fnutils.partial
local action = spoon.Modal.action
local wmAction = spoon.Windows.wmAction
local launchOrFocus = spoon.AppLauncher.launchOrFocus
local layoutAction = spoon.Layout.layoutAction
local registerGroup = spoon.Layout.registerGroup

-- community spoons
spoon.ReloadConfiguration:start()

spoon.Overlay:start({
  fontName = "Marker Felt",
  fontSize = 140,
  backgroundColor = { hue = 240 / 360, saturation = 0, brightness = 0, alpha = 0 },
  textColor = { hue = 240 / 360, saturation = 0.8, brightness = 0.8, alpha = 1 },
  borderColor = { hue = 240 / 360, saturation = 0.8, brightness = 0.4, alpha = 1 },
  borderWidth = 0,
  pollInterval = 0.1,
}, {
  ["co.podzim.BoltGPT"] = "AI-GPT",
  ["company.thebrowser.Browser"] = "Browser",
  ["com.microsoft.VSCode"] = "Code",
  ["com.microsoft.Outlook"] = "Mail",
  ["md.obsidian"] = "Notes",
  ["dev.warp.Warp-Stable"] = "Terminal",
})

-- spoon.Alert:start({
--   padding = 30,
--   borderRadius = 15,
--   fontSize = 28,
--   textColor = { hue = 0 / 360, saturation = 1, brightness = 0.9, alpha = 1 },
--   backgroundColor = { hue = 0 / 360, saturation = 0.6, brightness = 0.11, alpha = 1 },
--   borderColor = { hue = 0 / 360, saturation = 1, brightness = 0.6, alpha = 1 },
--   fadeInDuration = 0.5,
--   fadeOutDuration = 0.5,
--   motionDuration = 0.1,
--   placementPercentage = 50,
--   marginPercentage = 2,
--   minWidth = 250,
--   sliderLocation = "bottom",
-- })


--
-- register actions
--

-- command keys
--   a: AI - BoltAI
--   b: Browser - Arc
--   c: Code - VSCode
--   m: Mail - Outlook
--   n: Notes - Obsidian
--   t: Terminal - Warp

-- launchOrFocus
action({ {}, 'a' }, partial(launchOrFocus, 'BoltAI'), { group = 'primary' })
action({ {}, 'b' }, partial(launchOrFocus, 'Arc'), { group = 'primary' })
action({ {}, 'c' }, partial(launchOrFocus, 'Visual Studio Code'), { group = 'primary' })
action({ {}, 'm' }, partial(launchOrFocus, 'Microsoft Outlook'))
action({ {}, 'n' }, partial(launchOrFocus, 'Obsidian'))
action({ {}, 't' }, partial(launchOrFocus, 'Warp'), { group = 'primary' })
action({ {}, 'tab' }, nil, { group = 'primary', type = "next", loop = true })
action({ { "shift" }, 'tab' }, nil, { group = 'primary', type = "prev", loop = true })


-- layouts
local editorLayouts = {
  { { bundleID = "com.microsoft.VSCode", rect = { 0, 0, 1, 1 } },   { bundleID = "dev.warp.Warp-Stable", rect = { 0, 0.5, 1, 0.5 } } },
  { { bundleID = "com.microsoft.VSCode", rect = { 0, 0, 1, 0.7 } }, { bundleID = "dev.warp.Warp-Stable", rect = { 0, 0.7, 1, 0.3 } } },
  { { bundleID = "com.microsoft.VSCode", rect = { 0, 0, 1, 0.5 } }, { bundleID = "dev.warp.Warp-Stable", rect = { 0, 0, 1, 1 } } },
}
registerGroup("editor", editorLayouts, {})
action({ {}, 'e' }, partial(layoutAction, "editor", "forward"), { msg = 'Editor Layout' })


-- window management
action({ {}, 'up' }, partial(wmAction, "max"), { msg = 'Max' })
action({ {}, 'left' }, partial(wmAction, "left half"), { msg = 'Left Half' })
action({ {}, 'right' }, partial(wmAction, "right half"), { msg = 'Right Half' })
action({ {}, 'down' }, partial(wmAction, "scale center"), { msg = 'Center' })

action({ { "option", "cmd" }, 'up' }, partial(wmAction, "scale bigger"), { msg = 'Bigger' })
action({ { "option", "cmd" }, 'down' }, partial(wmAction, "scale smaller"), { msg = 'Smaller' })

action({ { 'cmd' }, 'up' }, partial(wmAction, "move up"), { msg = 'Move' })
action({ { 'cmd' }, 'down' }, partial(wmAction, "move down"), { msg = 'Move' })
action({ { 'cmd' }, 'left' }, partial(wmAction, "move left"), { msg = 'Move' })
action({ { 'cmd' }, 'right' }, partial(wmAction, "move right"), { msg = 'Move' })

action({ { "option" }, 'up' }, partial(wmAction, "stretch upper"), { msg = 'Stretch' })
action({ { "option" }, 'down' }, partial(wmAction, "stretch lower"), { msg = 'Stretch' })
action({ { "option" }, 'left' }, partial(wmAction, "stretch left"), { msg = 'Stretch' })
action({ { "option" }, 'right' }, partial(wmAction, "stretch right"), { msg = 'Stretch' })

action({ { "shift", "option" }, 'down' }, partial(wmAction, "shrink upper"), { msg = 'Shrink' })
action({ { "shift", "option" }, 'up' }, partial(wmAction, "shrink lower"), { msg = 'Shrink' })
action({ { "shift", "option" }, 'left' }, partial(wmAction, "shrink left"), { msg = 'Shrink' })
action({ { "shift", "option" }, 'right' }, partial(wmAction, "shrink right"), { msg = 'Shrink' })

-- actions
action({ {}, 'h' }, hs.toggleConsole)


-- intervals
-- action({ {}, 'pageup' }, partial(layoutAction, "editor", "forward"), { interval = 1, msg = "Editor Layout" }) -- fn + up = pageup
-- action({ { "cmd" }, 'a' }, partial(print, "Hello"), { interval = 2 })                                         -- cmd + a = hello every 2 seconds

-- I remap Caps Lock to f20 using Karabiner Elements
-- but you can use any hotkey you want
spoon.Modal:bindHotkeys({ toggle = { {}, 'f20' } })
