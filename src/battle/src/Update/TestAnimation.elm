module Update.TestAnimation exposing (apply_to)

-- Elm -------------------------------------------------------------------------
import Delay

import Time

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
   (
      (Struct.Model.initialize_animator model),
      (Delay.after 1 Delay.Millisecond Struct.Event.AnimationEnded)
   )
