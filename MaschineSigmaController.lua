------------------------------------------------------------------------------------------------------------------------
-- Maschine Studio Controller -- Sigma edition
------------------------------------------------------------------------------------------------------------------------

require "Scripts/Maschine/MaschineStudio/MaschineStudioController"
require "Scripts/Shared/Helpers/MaschineHelper"

local class = require 'Scripts/Shared/Helpers/classy'
-- Inherit from Maschine Studio to limit the scope of modifications
MaschineSigmaController = class( 'MaschineSigmaController', MaschineStudioController )

-- Expose constants for code that doesn't really handle inheritance
MaschineSigmaController.SCREEN_BUTTON_LEDS = MaschineStudioController.SCREEN_BUTTON_LEDS
MaschineSigmaController.SCREEN_BUTTONS = MaschineStudioController.SCREEN_BUTTONS
MaschineSigmaController.GROUP_LEDS = MaschineStudioController.GROUP_LEDS
MaschineSigmaController.JOGWHEEL_RING_LEDS = MaschineStudioController.JOGWHEEL_RING_LEDS
MaschineSigmaController.LEVELMETER_LEFT_LEDS = MaschineStudioController.LEVELMETER_LEFT_LEDS
MaschineSigmaController.LEVELMETER_RIGHT_LEDS = MaschineStudioController.LEVELMETER_RIGHT_LEDS
MaschineSigmaController.GROUP_BUTTONS = MaschineStudioController.GROUP_BUTTONS
MaschineStudioController.BUTTON_TO_PAGE = MaschineStudioController.BUTTON_TO_PAGE
MaschineSigmaController.LEDValues = MaschineStudioController.LEDValues

-- Add PAGE_FILE to the list of modifier pages
MaschineSigmaController.MODIFIER_PAGES = 
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
MaschineSigmaController.TEMPORARY_PAGES =
{
    NI.HW.PAGE_SAVE_AS
}

function MaschineSigmaController:__init()
    MaschineStudioController.__init(self)
end

-- Register additional pages to handle files
function MaschineSigmaController:createPages()
    MaschineStudioController.createPages(self)

    self.PageManager:register(NI.HW.PAGE_FILE, "Scripts/Maschine/MaschineSigma/FilePageSigma", "FilePageSigma", true)
    self.PageManager:register(NI.HW.PAGE_SAVE_AS, "Scripts/Maschine/Shared/Pages/SaveAsPage", "SaveAsPage", true)
end

-- Clear any temporary page when a button is activated
function MaschineSigmaController:onPageButton(Button, PageID, Pressed)
    MaschineStudioController.onPageButton(self, Button, PageID, Pressed)
    self:clearTempPage()
end

-- The following are adapted from MK3 File code
function MaschineSigmaController:onAllButton(Pressed)
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
        MaschineSigmaController.onPageButton(self, NI.HW.BUTTON_ALL, NI.HW.PAGE_FILE, Pressed)
    end
end

function MaschineSigmaController:clearTempPage()
    local TopPageID = NHLController:getPageStack():getTopPage()
    for Index, TempPageID in ipairs(MaschineSigmaController.TEMPORARY_PAGES) do
        if TopPageID ~= TempPageID then
            NHLController:getPageStack():removePage(TempPageID)
        end
    end
end

ControllerScriptInterface = MaschineSigmaController()
