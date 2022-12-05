------------------------------------------------------------------------------------------------------------------------
-- Maschine Studio Controller -- Sigma edition
------------------------------------------------------------------------------------------------------------------------

require "Scripts/Maschine/MaschineStudio/MaschineStudioController"
require "Scripts/Shared/Helpers/MaschineHelper"

local class = require 'Scripts/Shared/Helpers/classy'
-- Inherit from Maschine Studio to limit the scope of modifications
MaschineStudioSigmaController = class( 'MaschineStudioSigmaController', MaschineStudioController )

-- Expose constants for code that doesn't really handle inheritance
MaschineStudioSigmaController.SCREEN_BUTTON_LEDS = MaschineStudioController.SCREEN_BUTTON_LEDS
MaschineStudioSigmaController.SCREEN_BUTTONS = MaschineStudioController.SCREEN_BUTTONS
MaschineStudioSigmaController.GROUP_LEDS = MaschineStudioController.GROUP_LEDS
MaschineStudioSigmaController.JOGWHEEL_RING_LEDS = MaschineStudioController.JOGWHEEL_RING_LEDS
MaschineStudioSigmaController.LEVELMETER_LEFT_LEDS = MaschineStudioController.LEVELMETER_LEFT_LEDS
MaschineStudioSigmaController.LEVELMETER_RIGHT_LEDS = MaschineStudioController.LEVELMETER_RIGHT_LEDS
MaschineStudioSigmaController.GROUP_BUTTONS = MaschineStudioController.GROUP_BUTTONS
MaschineStudioSigmaController.BUTTON_TO_PAGE = MaschineStudioController.BUTTON_TO_PAGE
MaschineStudioSigmaController.LEDValues = MaschineStudioController.LEDValues

-- Add PAGE_FILE to the list of modifier pages
MaschineStudioSigmaController.MODIFIER_PAGES =
{
    NI.HW.PAGE_DUPLICATE,
    NI.HW.PAGE_GRID,
    NI.HW.PAGE_MUTE,
    NI.HW.PAGE_PAD,
    NI.HW.PAGE_NAVIGATE,
    NI.HW.PAGE_PAGE,
    NI.HW.PAGE_SCENE,
    NI.HW.PAGE_PATTERN,
    NI.HW.PAGE_REPEAT,
    NI.HW.PAGE_SELECT,
    NI.HW.PAGE_EVENTS,
    NI.HW.PAGE_SOLO,
    NI.HW.PAGE_VARIATION,

    NI.HW.PAGE_FILE
}

-- Define PAGE_SAVE_AS as a temporary page
MaschineStudioSigmaController.TEMPORARY_PAGES =
{
    NI.HW.PAGE_SAVE_AS
}

function MaschineStudioSigmaController:__init()
    MaschineStudioController.__init(self)
end

-- Register additional pages to handle files
function MaschineStudioSigmaController:createPages()
    MaschineStudioController.createPages(self)

    self.PageManager:register(NI.HW.PAGE_FILE, "Scripts/Maschine/MaschineStudioSigma/FilePageSigma", "FilePageSigma", true)
    self.PageManager:register(NI.HW.PAGE_SAVE_AS, "Scripts/Maschine/Shared/Pages/SaveAsPage", "SaveAsPage", true)
end

-- Clear any temporary page when a button is activated
function MaschineStudioSigmaController:onPageButton(Button, PageID, Pressed)
    MaschineStudioController.onPageButton(self, Button, PageID, Pressed)
    self:clearTempPage()
end

-- The following are adapted from MK3 File code
function MaschineStudioSigmaController:onAllButton(Pressed)
    local PageStack = NHLController:getPageStack()

    if NHLController:isInModalState() then
        return
    end

    if self:getShiftPressed() then
        if PageStack:getTopPage() ~= NI.HW.PAGE_FILE and PageStack:getTopPage() ~= NI.HW.PAGE_SAVE_AS then
            LEDHelper.updateButtonLED(self, NI.HW.LED_ALL, NI.HW.BUTTON_ALL, Pressed)
        end
        if Pressed then
            local InfoBarTempMode = NHLController:getPageStack():getTopPage() == NI.HW.PAGE_FILE and "FilePageProjectSaved"
            MaschineHelper.saveProject(self:getInfoBar(), InfoBarTempMode)
        end
    else
        MaschineStudioSigmaController.onPageButton(self, NI.HW.BUTTON_ALL, NI.HW.PAGE_FILE, Pressed)
    end
end

function MaschineStudioSigmaController:clearTempPage()
    local TopPageID = NHLController:getPageStack():getTopPage()
    for Index, TempPageID in ipairs(MaschineStudioSigmaController.TEMPORARY_PAGES) do
        if TopPageID ~= TempPageID then
            NHLController:getPageStack():removePage(TempPageID)
        end
    end
end

ControllerScriptInterface = MaschineStudioSigmaController()
