module Update.SelectTab exposing (apply_to)

-- Local Module ----------------------------------------------------------------
import Struct.Model
import Struct.Event
import Struct.UI

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
apply_to : (
      Struct.Model.Type ->
      Struct.UI.Tab ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
apply_to model tab =
   (
      {model | ui = (Struct.UI.set_displayed_tab tab model.ui)},
      Cmd.none
   )
