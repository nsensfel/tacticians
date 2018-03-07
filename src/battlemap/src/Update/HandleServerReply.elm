module Update.HandleServerReply exposing (apply_to)

-- Elm -------------------------------------------------------------------------
import Http

-- Battlemap -------------------------------------------------------------------
import Struct.Error
import Struct.Event
import Struct.Model

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
apply_to : (
      Struct.Model.Type ->
      (Result Http.Error (List (List String))) ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
apply_to model query_result =
   case query_result of
      (Result.Err error) ->
         (
            (Struct.Model.invalidate
               model
               (Struct.Error.new Struct.Error.Networking (toString error))
            ),
            Cmd.none
         )

      (Result.Ok commands) ->
         (
            (Struct.Model.invalidate
               model
               (Struct.Error.new Struct.Error.Unimplemented "Network Comm.")
            ),
            Cmd.none
         )
