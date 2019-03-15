module Update.SendLoadBattleRequest exposing (apply_to)

-- Local Module ----------------------------------------------------------------
import Comm.LoadBattle

import Struct.Event
import Struct.Model

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
apply_to : Struct.Model.Type -> (Struct.Model.Type, (Cmd Struct.Event.Type))
apply_to model =
   (
      (Struct.Model.full_debug_reset model),
      (case (Comm.LoadBattle.try model) of
         (Just cmd) -> cmd
         Nothing -> Cmd.none
      )
   )

