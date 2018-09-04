module ElmModule.Subscriptions exposing (..)

-- Elm -------------------------------------------------------------------------

-- Main Menu -------------------------------------------------------------------
import Action.Session

import Struct.Model
import Struct.Event

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
subscriptions : Struct.Model.Type -> (Sub Struct.Event.Type)
subscriptions model =
   (Action.Session.connected (always Struct.Event.Connected))
