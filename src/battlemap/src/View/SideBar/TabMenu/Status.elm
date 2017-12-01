module View.SideBar.TabMenu.Status exposing (get_html)

-- Elm -------------------------------------------------------------------------
import Dict

import Html
import Html.Attributes

-- Battlemap -------------------------------------------------------------------
import Battlemap
import Battlemap.Location
import Battlemap.Tile

import Character

import UI

import Util.Html

import Error
import Event
import Model

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

get_char_info_html : Model.Type -> Character.Ref -> (Html.Html Event.Type)
get_char_info_html model char_ref =
   case (Dict.get char_ref model.characters) of
      Nothing -> (Html.text "Error: Unknown character selected.")
      (Just char) ->
         (Html.text
            (
               "Focusing "
               ++ char.name
               ++ " (Team "
               ++ (toString (Character.get_team char))
               ++ "): "
               ++ (toString (Character.get_movement_points char))
               ++ " movement points; "
               ++ (toString (Character.get_attack_range char))
               ++ " attack range. Health: "
               ++ (toString (Character.get_current_health char))
               ++ "/"
               ++ (toString (Character.get_max_health char))
            )
         )

get_char_attack_info_html : Model.Type -> Character.Ref -> (Html.Html Event.Type)
get_char_attack_info_html model char_ref =
   case (Dict.get char_ref model.characters) of
      Nothing -> (Html.text "Error: Unknown character selected.")
      (Just char) ->
         (Html.text
            (
               "Attacking "
               ++ char.name
               ++ " (Team "
               ++ (toString (Character.get_team char))
               ++ "): "
               ++ (toString (Character.get_movement_points char))
               ++ " movement points; "
               ++ (toString (Character.get_attack_range char))
               ++ " attack range. Health: "
               ++ (toString (Character.get_current_health char))
               ++ "/"
               ++ (toString (Character.get_max_health char))
            )
         )

get_error_html : Error.Type -> (Html.Html Event.Type)
get_error_html err =
   (Html.div
      [
         (Html.Attributes.class "battlemap-tabmenu-error-message")
      ]
      [
         (Html.text (Error.to_string err))
      ]
   )

get_tile_info_html : (
      Model.Type ->
      Battlemap.Location.Type ->
      (Html.Html Event.Type)
   )
get_tile_info_html model loc =
   case (Battlemap.try_getting_tile_at model.battlemap loc) of
      (Just tile) ->
         (Html.div
            [
               (Html.Attributes.class
                  "battlemap-tabmenu-tile-info-tab"
               )
            ]
            [
               (Html.div
                  [
                     (Html.Attributes.class "battlemap-tile-icon"),
                     (Html.Attributes.class "battlemap-tiled"),
                     (Html.Attributes.class
                        (
                           "asset-tile-"
                           ++
                           (Battlemap.Tile.get_icon_id tile)
                        )
                     )
                  ]
                  [
                  ]
               ),
               (Html.div
                  [
                  ]
                  [
                     (Html.text
                        (
                           "Focusing tile ("
                           ++ (toString loc.x)
                           ++ ", "
                           ++ (toString loc.y)
                           ++ "). {ID = "
                           ++ (Battlemap.Tile.get_icon_id tile)
                           ++ ", cost = "
                           ++ (toString (Battlemap.Tile.get_cost tile))
                           ++ "}."
                        )
                     )
                  ]
               )
            ]
         )

      Nothing -> (Html.text "Error: Unknown tile location selected.")

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
get_html : Model.Type -> (Html.Html Event.Type)
get_html model =
   (Html.div
      [
         (Html.Attributes.class "battlemap-footer-tabmenu-content"),
         (Html.Attributes.class "battlemap-footer-tabmenu-content-status")
      ]
      (case model.state of
         (Model.InspectingTile tile_loc) ->
            [(get_tile_info_html model (Battlemap.Location.from_ref tile_loc))]

         (Model.InspectingCharacter char_ref) ->
            [(get_char_info_html model char_ref)]

         _ ->
            [
               (case (UI.get_previous_action model.ui) of
                  (Just (UI.SelectedLocation loc)) ->
                     (get_tile_info_html
                        model
                        (Battlemap.Location.from_ref loc)
                     )

                  (Just (UI.SelectedCharacter target_char)) ->
                     (get_char_info_html model target_char)

                  _ ->
                     (Html.text "Double-click on a character to control it.")
               )
            ]
      )
   )