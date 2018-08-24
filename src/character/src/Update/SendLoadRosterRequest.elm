module Update.SendLoadRosterRequest exposing (apply_to)
-- Elm -------------------------------------------------------------------------

-- Map -------------------------------------------------------------------
import Comm.LoadRoster

import Struct.Event
import Struct.Model

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
apply_to : (
      Struct.Model.Type ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
apply_to model =
   (
      (Struct.Model.reset model),
      (case (Comm.LoadRoster.try model) of
         (Just cmd) -> cmd
         Nothing -> Cmd.none
      )
   )

