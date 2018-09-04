module Update.HandleConnected exposing (apply_to)
-- Elm -------------------------------------------------------------------------

-- Login -----------------------------------------------------------------------
import Action.Session

import Constants.IO

import Struct.Model
import Struct.Event
import Struct.UI

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
      (Action.Session.go_to (Constants.IO.base_url ++"/main-menu/"))
   )
