------------------------------------------------------------------------------------------------------------------------

require "Scripts/Maschine/MaschineMK3/Pages/FilePageMK3"

------------------------------------------------------------------------------------------------------------------------

local class = require 'Scripts/Shared/Helpers/classy'
FilePageSigma = class( 'FilePageSigma', FilePageMK3 )

------------------------------------------------------------------------------------------------------------------------

function FilePageSigma:__init(Controller)

    FilePageMK3.__init(self, Controller)
    self.Name = "FilePageSigma"
    self.PageLEDs = { NI.HW.LED_ALL }

end
