module View.GlyphBoardSelection exposing (get_html)

-- Elm -------------------------------------------------------------------------
import Dict

import Html
import Html.Attributes
import Html.Events

-- Battle ----------------------------------------------------------------------
import Battle.View.Omnimods

-- Battle Characters -----------------------------------------------------------
import BattleCharacters.Struct.GlyphBoard

-- Local Module ----------------------------------------------------------------
import Struct.Event
import Struct.Model

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
get_mod_html : (String, Int) -> (Html.Html Struct.Event.Type)
get_mod_html mod =
   let
      (category, value) = mod
   in
      (Html.div
         [
            (Html.Attributes.class "info-card-mod")
         ]
         [
            (Html.text
               (category ++ ": " ++ (String.fromInt value))
            )
         ]
      )

get_glyph_board_html : (
      BattleCharacters.Struct.GlyphBoard.Type ->
      (Html.Html Struct.Event.Type)
   )
get_glyph_board_html glyph_board =
   (Html.div
      [
         (Html.Attributes.class "character-card-glyph-board"),
         (Html.Attributes.class "clickable"),
         (Html.Events.onClick
            (Struct.Event.SelectedGlyphBoard
               (BattleCharacters.Struct.GlyphBoard.get_id glyph_board)
            )
         )
      ]
      [
         (Html.div
            [
               (Html.Attributes.class "character-card-glyph-board-name")
            ]
            [
               (Html.text
                  (BattleCharacters.Struct.GlyphBoard.get_name glyph_board)
               )
            ]
         ),
         (Battle.View.Omnimods.get_html
            (BattleCharacters.Struct.GlyphBoard.get_omnimods glyph_board)
         )
      ]
   )

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
get_html : Struct.Model.Type -> (Html.Html Struct.Event.Type)
get_html model =
   (Html.div
      [
         (Html.Attributes.class "selection-window"),
         (Html.Attributes.class "glyph-board-selection")
      ]
      [
         (Html.text "Glyph Board Selection"),
         (Html.div
            [
               (Html.Attributes.class "selection-window-listing")
            ]
            (List.map (get_glyph_board_html) (Dict.values model.glyph_boards))
         )
      ]
   )
