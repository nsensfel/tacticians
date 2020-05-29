module Update.SelectTile exposing (apply_to)

-- Battle Map -------------------------------------------------------------------
import BattleMap.Struct.Direction
import BattleMap.Struct.Location
import BattleMap.Struct.Map

-- Battle Characters ------------------------------------------------------------
import BattleCharacters.Struct.Character

-- Local Module ----------------------------------------------------------------
import Struct.Battle
import Struct.Character
import Struct.CharacterTurn
import Struct.Error
import Struct.Event
import Struct.Model
import Struct.Navigator
import Struct.UI

import Update.CharacterTurn.UndoAction

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
maybe_autopilot : (
      BattleMap.Struct.Direction.Type ->
      (Maybe Struct.Navigator.Type) ->
      (Maybe Struct.Navigator.Type)
   )
maybe_autopilot dir maybe_navigator =
   case maybe_navigator of
      (Just navigator) ->
         (Struct.Navigator.maybe_add_step dir navigator)

      Nothing -> Nothing

go_to_current_tile : (
      Struct.Model.Type ->
      BattleMap.Struct.Location.Ref ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
go_to_current_tile model loc_ref =
   if
   (
      (Struct.UI.get_previous_action model.ui)
      ==
      (Just (Struct.UI.SelectedLocation loc_ref))
   )
   then
      -- And we just clicked on that tile.
      (
         {model |
            char_turn =
               case
                  (Struct.CharacterTurn.maybe_get_navigator model.char_turn)
               of
                  (Just nav) ->
                     (Struct.CharacterTurn.set_navigator
                        (Struct.Navigator.lock_path nav)
                        (Struct.CharacterTurn.store_path model.char_turn)
                     )

                  Nothing -> model.char_turn
         },
         Cmd.none
      )
   else
      -- And we didn't just click on that tile.
      (
         {model |
            ui =
               (Struct.UI.clear_displayed_navigator
                  (Struct.UI.set_displayed_tab
                     (Struct.UI.TileStatusTab loc_ref)
                     (Struct.UI.set_previous_action
                        (Just (Struct.UI.SelectedLocation loc_ref))
                        model.ui
                     )
                  )
               )
         },
         Cmd.none
      )

go_to_another_tile : (
      Struct.Model.Type ->
      Struct.Character.Type ->
      Struct.Navigator.Type ->
      BattleMap.Struct.Location.Ref ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
go_to_another_tile model char navigator loc_ref =
   case (Struct.Navigator.maybe_get_path_to loc_ref navigator) of
      (Just path) ->
         case
            (List.foldr
               (maybe_autopilot)
               (Just (Struct.Navigator.clear_path navigator))
               path
            )
         of
            (Just new_navigator) ->
               (
                  {model |
                     char_turn =
                        (Struct.CharacterTurn.set_navigator
                           new_navigator
                           (Struct.CharacterTurn.set_active_character
                              (Struct.Character.set_base_character
                                 (BattleCharacters.Struct.Character.set_extra_omnimods
                                    (BattleMap.Struct.Map.get_omnimods_at
                                       (Struct.Navigator.get_current_location
                                          new_navigator
                                       )
                                       model.map_data_set
                                       (Struct.Battle.get_map model.battle)
                                    )
                                    (Struct.Character.get_base_character char)
                                 )
                                 char
                              )
                              model.char_turn
                           )
                        ),
                     ui =
                        (Struct.UI.set_displayed_tab
                           (Struct.UI.TileStatusTab loc_ref)
                           (Struct.UI.set_previous_action
                              (Just (Struct.UI.SelectedLocation loc_ref))
                              model.ui
                           )
                        )
                  },
                  Cmd.none
               )

            Nothing ->
               (
                  (Struct.Model.invalidate
                     (Struct.Error.new
                        Struct.Error.Programming
                        "SelectTile/Navigator: Could not follow own path."
                     )
                     model
                  ),
                  Cmd.none
               )

      Nothing -> -- Clicked outside of the range indicator
         if
         (
            (Struct.UI.maybe_get_displayed_tab model.ui)
            == (Just (Struct.UI.TileStatusTab loc_ref))
         )
         then (Update.CharacterTurn.UndoAction.apply_to model)
         else
            (
               {model |
                  ui =
                     (Struct.UI.set_displayed_tab
                        (Struct.UI.TileStatusTab loc_ref)
                        (Struct.UI.set_previous_action
                           (Just (Struct.UI.SelectedLocation loc_ref))
                           model.ui
                        )
                     )
               },
               Cmd.none
            )

go_to_tile : (
      Struct.Model.Type ->
      Struct.Character.Type ->
      Struct.Navigator.Type ->
      BattleMap.Struct.Location.Ref ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
go_to_tile model char navigator loc_ref =
   if
   (
      loc_ref
      ==
      (BattleMap.Struct.Location.get_ref
         (Struct.Navigator.get_current_location navigator)
      )
   )
   then (go_to_current_tile model loc_ref)
   else (go_to_another_tile model char navigator loc_ref)

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
apply_to : (
      BattleMap.Struct.Location.Ref ->
      Struct.Model.Type ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
apply_to loc_ref model =
   case
      (
         (Struct.UI.maybe_get_displayed_navigator model.ui),
         (Struct.CharacterTurn.maybe_get_navigator model.char_turn),
         (Struct.CharacterTurn.maybe_get_active_character model.char_turn)
      )
   of
      (Nothing, (Just navigator), (Just char)) ->
         (go_to_tile model char navigator loc_ref)

      _ ->
         (
            {model |
               ui =
                  (Struct.UI.clear_displayed_navigator
                     (Struct.UI.set_displayed_tab
                        (Struct.UI.TileStatusTab loc_ref)
                        (Struct.UI.set_previous_action
                           (Just (Struct.UI.SelectedLocation loc_ref))
                           model.ui
                        )
                     )
                  )
            },
            Cmd.none
         )
