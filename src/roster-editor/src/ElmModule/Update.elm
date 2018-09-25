module ElmModule.Update exposing (update)

-- Elm -------------------------------------------------------------------------

-- Roster Editor ---------------------------------------------------------------
import Struct.Event
import Struct.Model

import Update.GoToMainMenu
import Update.HandleServerReply
import Update.SelectCharacter
import Update.SelectTab
import Update.SetRequestedHelp

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------

update : (
      Struct.Event.Type ->
      Struct.Model.Type ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
update event model =
   let
      new_model = (Struct.Model.clear_error model)
   in
   case event of
      Struct.Event.None -> (model, Cmd.none)

      (Struct.Event.Failed err) ->
         (
            (Struct.Model.invalidate err new_model),
            Cmd.none
         )

      (Struct.Event.CharacterSelected char_id) ->
         (Update.SelectCharacter.apply_to new_model char_id)

      (Struct.Event.TabSelected tab) ->
         (Update.SelectTab.apply_to new_model tab)

      (Struct.Event.ServerReplied result) ->
         (Update.HandleServerReply.apply_to model result)

      (Struct.Event.RequestedHelp help_request) ->
         (Update.SetRequestedHelp.apply_to new_model help_request)

      Struct.Event.GoToMainMenu ->
         (Update.GoToMainMenu.apply_to new_model)