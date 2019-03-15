module Update.SetToolboxShape exposing (apply_to)

-- Local module ----------------------------------------------------------------
import Struct.Event
import Struct.Toolbox
import Struct.Model

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
apply_to : (
      Struct.Model.Type ->
      Struct.Toolbox.Shape ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
apply_to model shape =
   (
      {model | toolbox = (Struct.Toolbox.set_shape shape model.toolbox)},
      Cmd.none
   )
