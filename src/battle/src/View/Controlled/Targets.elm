module View.SideBar.Targets exposing (get_html)

-- Elm -------------------------------------------------------------------------
import Dict

import Html
import Html.Attributes

-- Battle ----------------------------------------------------------------------
import Battle.Struct.Attributes

-- Local Module ----------------------------------------------------------------
import Struct.Character
import Struct.Event
import Struct.Model

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

get_target_info_html : (
      Struct.Model.Type ->
      Struct.Character.Ref ->
      (Html.Html Struct.Event.Type)
   )
get_target_info_html model char_ref =
   case (Dict.get char_ref model.characters) of
      Nothing -> (Html.text "Error: Unknown character selected.")
      (Just char) ->
         (Html.text
            (
               "Attacking "
               ++ char.name
               ++ " (player "
               ++ (String.fromInt (Struct.Character.get_player_index char))
               ++ "): "
               ++
               (String.fromInt
                  (Battle.Struct.Attributes.get_movement_points
                     (Struct.Character.get_attributes char)
                  )
               )
               ++ " movement points; "
               ++ "???"
               ++ " attack range. Health: "
               ++
               (String.fromInt
                  (Struct.Character.get_sane_current_health char)
               )
               ++ "/"
               ++
               (String.fromInt
                  (Battle.Struct.Attributes.get_max_health
                     (Struct.Character.get_attributes char)
                  )
               )
            )
         )

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
get_html : (
      Struct.Model.Type ->
      Struct.Character.Ref ->
      (Html.Html Struct.Event.Type)
   )
get_html model target_ref =
   (Html.div
      [
         (Html.Attributes.class "side-bar-targets")
      ]
      [(get_target_info_html model target_ref)]
   )
