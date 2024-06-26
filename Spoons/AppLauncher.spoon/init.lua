local module = {}
module.__index = module

--
-- Metadata
--
module.name = 'AppLauncher'
module.version = '1.0'
module.author = "{ ken }"
module.homepage = "https://github.com/kenbankspeng/hammerspoon-config"
module.license = 'MIT - https://opensource.org/licenses/MIT'


-- convert from appName to bundleID where possible
-- the use cached method for subsequent calls



local function getBundleIdFromCmd(appName)
    local bundleID = nil
    local appPath = '/Applications/' .. appName:gsub(' ', '\\ ') .. '.app'
    local command = 'mdls -name kMDItemCFBundleIdentifier ' .. appPath
    local output, status = hs.execute(command)
    if output and status then
        bundleID = output:match('kMDItemCFBundleIdentifier%s=%s"([^"]+)"')
    end
    return bundleID
end

local function getApp(appName)
    if not appName then return end

    local app = nil
    app = hs.application.get(appName)
    -- fallback - go to commandline
    if not app then
        local bundleID = getBundleIdFromCmd(appName)
        app = bundleID and hs.application.get(bundleID)
    end

    return app
end

--
-- launch or focus apps
--
function module.launchOrFocus(appName)
    if not appName then return end

    local app = getApp(appName)
    local bundleID = app and app:bundleID()

    -- if possible, use launchOrFocusByBundleID(bundleID)
    if bundleID then
        hs.application.launchOrFocusByBundleID(bundleID)
    else
        hs.application.launchOrFocus(appName)
    end
end

return module
