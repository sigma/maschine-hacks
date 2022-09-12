------------------------------------------------------------------------------------------------------------------------
-- Maschine Studio Controller -- Sigma edition
------------------------------------------------------------------------------------------------------------------------

require "Scripts/Maschine/MaschineStudio/MaschineStudioController"
require "Scripts/Shared/Helpers/MaschineHelper"

------------------------------------------------------------------------------------------------------------------------

local class = require 'Scripts/Shared/Helpers/classy'
MaschineSigmaController = class( 'MaschineSigmaController', MaschineStudioController )

------------------------------------------------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------------------------------------------------

MaschineSigmaController.SCREEN_BUTTON_LEDS = MaschineStudioController.SCREEN_BUTTON_LEDS
MaschineSigmaController.SCREEN_BUTTONS = MaschineStudioController.SCREEN_BUTTONS
MaschineSigmaController.GROUP_LEDS = MaschineStudioController.GROUP_LEDS
MaschineSigmaController.JOGWHEEL_RING_LEDS = MaschineStudioController.JOGWHEEL_RING_LEDS
MaschineSigmaController.LEVELMETER_LEFT_LEDS = MaschineStudioController.LEVELMETER_LEFT_LEDS
MaschineSigmaController.LEVELMETER_RIGHT_LEDS = MaschineStudioController.LEVELMETER_RIGHT_LEDS
MaschineSigmaController.GROUP_BUTTONS = MaschineStudioController.GROUP_BUTTONS
MaschineStudioController.BUTTON_TO_PAGE = MaschineStudioController.BUTTON_TO_PAGE
MaschineSigmaController.LEDValues = MaschineStudioController.LEDValues

------------------------------------------------------------------------------------------------------------------------

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

MaschineSigmaController.TEMPORARY_PAGES =
{
    NI.HW.PAGE_SAVE_AS
}

------------------------------------------------------------------------------------------------------------------------
-- init
------------------------------------------------------------------------------------------------------------------------

function MaschineSigmaController:__init()

    MaschineStudioController.__init(self)

end

------------------------------------------------------------------------------------------------------------------------

function MaschineSigmaController:createPages()

    MaschineStudioController.createPages(self)

    -- register pages
    local Sigma = "Scripts/Maschine/MaschineSigma/Pages/"
    local MaschineShared = "Scripts/Maschine/Shared/Pages/"

    self.PageManager:register(NI.HW.PAGE_FILE, Sigma .. "FilePageSigma", "FilePageSigma", true)
    self.PageManager:register(NI.HW.PAGE_SAVE_AS, MaschineShared .. "SaveAsPage", "SaveAsPage", true)

end

------------------------------------------------------------------------------------------------------------------------

function MaschineSigmaController:onPageButton(Button, PageID, Pressed)

    MaschineStudioController.onPageButton(self, Button, PageID, Pressed)
    self:clearTempPage()

end

------------------------------------------------------------------------------------------------------------------------

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

-- Create Instance
ControllerScriptInterface = MaschineSigmaController()
