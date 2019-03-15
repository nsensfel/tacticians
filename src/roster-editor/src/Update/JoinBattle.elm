module Update.JoinBattle exposing (apply_to)

-- Local Module ----------------------------------------------------------------
import Comm.JoinBattle

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
      model,
      (case (Comm.JoinBattle.try model) of
         (Just cmd) -> cmd
         Nothing -> Cmd.none
      )
   )

