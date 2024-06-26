local group = dofile(hs.spoons.resourcePath("helper.lua"))

local Alert = {}
Alert.__index = Alert

-- Metadata
Alert.name = "Alert"
Alert.version = "1.1"
Alert.author = "{ ken }"
Alert.homepage = "https://github.com/kenbankspeng/hammerspoon-config"
Alert.license = "MIT - https://opensource.org/licenses/MIT"

local defaultConfig = {
  padding = 20,
  borderRadius = 10,
  fontSize = 24,
  textColor = { hue = 194 / 360, saturation = 1, brightness = 0.9, alpha = 1 },
  backgroundColor = { hue = 194 / 360, saturation = 0.6, brightness = 0.11, alpha = 1 },
  gradient = nil,
  borderColor = { hue = 194 / 360, saturation = 1, brightness = 0.6, alpha = 1 },
  fadeInDuration = 0.3,
  fadeOutDuration = 0.3,
  motionDuration = 0.05,
  placementPercentage = 50,
  marginPercentage = 0,
  minWidth = 200,
  sliderLocation = "bottom",
  animationSteps = 10,
}

local canvas = nil
local initialX, initialY, finalX, finalY
local activeConfig = {}

-- Show a new canvas with animation
local function showNewCanvas(msg, options, initialX, initialY, finalX, finalY, boxWidth, boxHeight)
  canvas = group.createCanvasElement(options, boxWidth, boxHeight, initialX, initialY)
  assert(canvas, "Failed to create canvas")

  canvas:alpha(0)
  canvas:show(0)

  hs.timer.doAfter(0.01, function()
    group.animateCanvasMovement(canvas, { x = initialX, y = initialY, w = boxWidth, h = boxHeight },
      { x = finalX, y = finalY, w = boxWidth, h = boxHeight }, options.motionDuration, activeConfig.animationSteps,
      function()
        group.updateCanvasText(canvas, msg, options)
      end)

    hs.timer.doAfter(options.motionDuration / defaultConfig.animationSteps, function()
      local currentStep = 0
      local stepDuration = options.motionDuration / defaultConfig.animationSteps
      local function fadeStep()
        if currentStep < defaultConfig.animationSteps then
          currentStep = currentStep + 1
          canvas:alpha(currentStep / defaultConfig.animationSteps)
          hs.timer.doAfter(stepDuration, fadeStep)
        end
      end
      fadeStep()
    end)
  end)
end

-- Show an existing canvas without recreating it
local function showExistingCanvas(msg, options, finalX, finalY, boxWidth, boxHeight)
  if canvas then canvas:delete() end
  canvas = group.createCanvasElement(options, boxWidth, boxHeight, finalX, finalY)
  assert(canvas, "Failed to create canvas")

  canvas:frame({ x = finalX, y = finalY, w = boxWidth, h = boxHeight })
  canvas:show(0)
  group.updateCanvasText(canvas, msg, options)
end

-- Display the alert
function Alert:show(msg, overrides)
  activeConfig = group.getConfig(overrides, defaultConfig)

  local screenFrame = hs.screen.mainScreen():fullFrame()
  local styledText = hs.styledtext.new(msg, { font = { name = 'Helvetica', size = activeConfig.fontSize } })
  local textSize = hs.drawing.getTextDrawingSize(styledText) or { w = 50, h = 10 }
  local boxWidth = math.max(textSize.w + activeConfig.padding * 2, activeConfig.minWidth)
  local boxHeight = textSize.h + activeConfig.padding * 2

  initialX, initialY, finalX, finalY = group.calculateSlidePositions(activeConfig, screenFrame, boxWidth, boxHeight)

  if not canvas then
    showNewCanvas(msg, activeConfig, initialX, initialY, finalX, finalY, boxWidth, boxHeight)
  elseif activeConfig.redraw then
    showExistingCanvas(msg, activeConfig, finalX, finalY, boxWidth, boxHeight)
  else
    group.updateCanvasText(canvas, msg, activeConfig)
  end
end

-- Clear the alert
function Alert:clear()
  if not canvas then return end

  local alertCanvas = canvas
  canvas = nil

  group.animateCanvasMovement(alertCanvas,
    { x = finalX, y = finalY, w = alertCanvas:frame().w, h = alertCanvas:frame().h },
    { x = initialX, y = initialY, w = alertCanvas:frame().w, h = alertCanvas:frame().h }, activeConfig.motionDuration,
    activeConfig.animationSteps, function()
      alertCanvas:hide(0)
      hs.timer.doAfter(0.01, function()
        if alertCanvas then alertCanvas:delete() end
      end)
    end)
end

-- Start the alert system with custom configuration
function Alert:start(customConfig)
  if customConfig then
    for k, v in pairs(customConfig) do
      defaultConfig[k] = v
    end
  end
end

return Alert
