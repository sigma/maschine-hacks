------------------------------------------------------------------------------------------------------------------------

require "Scripts/Maschine/Components/Pages/SaveDialogPageBase"

------------------------------------------------------------------------------------------------------------------------

local class = require 'Scripts/Shared/Helpers/classy'
SaveDialogPageStudio = class( 'SaveDialogPageStudio', SaveDialogPageBase )

------------------------------------------------------------------------------------------------------------------------
-- init
------------------------------------------------------------------------------------------------------------------------

function SaveDialogPageStudio:__init(Controller)

    SaveDialogPageBase.__init(self, Controller, "SaveDialogPageStudio")

end

------------------------------------------------------------------------------------------------------------------------

function SaveDialogPageStudio:setupScreen()

    SaveDialogPageBase.setupScreen(self)

    self.LeftLabel:setText("Save Project")
    self.RightLabel:setText("The project was modified. Do you want to save it?")

end
