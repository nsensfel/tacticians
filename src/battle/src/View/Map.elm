module View.Map exposing (get_html)

-- Elm -------------------------------------------------------------------------
import Array

import Html
import Html.Attributes
import Html.Lazy

import List

-- Shared ----------------------------------------------------------------------
import Util.Html

-- Battle Map ------------------------------------------------------------------
import BattleMap.Struct.Map

import BattleMap.View.Tile

-- Local Module ----------------------------------------------------------------
import Constants.UI

import Struct.Character
import Struct.Event
import Struct.Model
import Struct.Navigator
import Struct.UI

import View.Map.Character
import View.Map.Navigator

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
get_tiles_html : BattleMap.Struct.Map.Type -> (Html.Html Struct.Event.Type)
get_tiles_html map =
   (Html.div
      [
         (Html.Attributes.class "tiles-layer"),
         (Html.Attributes.style
            "width"
            (
               (String.fromInt
                  (
                     (BattleMap.Struct.Map.get_width map)
                     * Constants.UI.tile_size
                  )
               )
               ++ "px"
            )
         ),
         (Html.Attributes.style
            "height"
            (
               (String.fromInt
                  (
                     (BattleMap.Struct.Map.get_height map)
                     * Constants.UI.tile_size
                  )
               )
               ++ "px"
            )
         )
      ]
      (List.map
         (BattleMap.View.Tile.get_html False)
         (Array.toList (BattleMap.Struct.Map.get_tiles map))
      )
   )

maybe_print_navigator : (
      Bool ->
      (Maybe Struct.Navigator.Type) ->
      (Html.Html Struct.Event.Type)
   )
maybe_print_navigator interactive maybe_nav =
   let
      name_suffix =
         if (interactive)
         then
            "interactive"
         else
            "non-interactive"
   in
      case maybe_nav of
         (Just nav) ->
            (Html.div
               [
                  (Html.Attributes.class ("navigator" ++ name_suffix))
               ]
               (View.Map.Navigator.get_html
                  (Struct.Navigator.get_summary nav)
                  interactive
               )
            )

         Nothing ->
            (Util.Html.nothing)

get_characters_html : (
      Struct.Model.Type ->
      (Array.Array Struct.Character.Type) ->
      (Html.Html Struct.Event.Type)
   )
get_characters_html model characters =
   (Html.div
      [
         (Html.Attributes.class "characters")
      ]
      (List.map
         (View.Map.Character.get_html model)
         (Array.toList model.characters)
      )
   )

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
get_html : (
      Struct.Model.Type ->
      (Html.Html Struct.Event.Type)
   )
get_html model =
   (Html.div
      [
         (Html.Attributes.class "actual"),
         (
            if ((Struct.UI.get_zoom_level model.ui) == 1)
            then (Html.Attributes.style "" "")
            else
               (Html.Attributes.style
                  "transform"
                  (
                     "scale("
                     ++
                     (String.fromFloat
                        (Struct.UI.get_zoom_level model.ui)
                     )
                     ++ ")"
                  )
               )
         )
      ]
      [
         (Html.Lazy.lazy (get_tiles_html) model.map),
         -- Not in lazy mode, because I can't easily get rid of that 'model'
         -- parameter.
         (get_characters_html model model.characters),
         (Html.Lazy.lazy2
            (maybe_print_navigator)
            True
            model.char_turn.navigator
         ),
         (Html.Lazy.lazy2
            (maybe_print_navigator)
            False
            (Struct.UI.try_getting_displayed_nav model.ui)
         )
      ]
   )
