module Update.SwitchTeam exposing (apply_to)

-- Local Module ----------------------------------------------------------------
import Struct.Model
import Struct.Event

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
apply_to : Struct.Model.Type -> (Struct.Model.Type, (Cmd Struct.Event.Type))
apply_to model =
   if (model.player_ix == 0)
   then
      (
         (Struct.Model.reset {model | player_id = "1", player_ix = 1}),
         Cmd.none
      )
   else
      (
         (Struct.Model.reset {model | player_id = "0", player_ix = 0}),
         Cmd.none
      )
