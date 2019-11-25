module View.GlyphSelection exposing (get_html)

-- Elm -------------------------------------------------------------------------
import Array

import Set

import Dict

import Html
import Html.Lazy
import Html.Attributes
import Html.Events

-- Shared ----------------------------------------------------------------------
import Util.Html

-- Battle ----------------------------------------------------------------------
import Battle.Struct.Omnimods

import Battle.View.Omnimods

-- Battle Characters -----------------------------------------------------------
import BattleCharacters.Struct.DataSet
import BattleCharacters.Struct.Character
import BattleCharacters.Struct.Equipment
import BattleCharacters.Struct.Glyph
import BattleCharacters.Struct.GlyphBoard

-- Local Module ----------------------------------------------------------------
import Struct.Character
import Struct.Event
import Struct.Model
import Struct.UI

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
get_mod_html : (String, Int) -> (Html.Html Struct.Event.Type)
get_mod_html mod =
   let (category, value) = mod in
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

get_glyph_html : (
      (Set.Set BattleCharacters.Struct.Glyph.Ref) ->
      Float ->
      BattleCharacters.Struct.Glyph.Type ->
      (Html.Html Struct.Event.Type)
   )
get_glyph_html invalid_family_ids factor glyph =
   (Html.div
      [
         (Html.Attributes.class "character-card-glyph"),
         (Html.Attributes.class "clickable"),
         (Html.Attributes.class
            (
               if
                  (Set.member
                     (BattleCharacters.Struct.Glyph.get_family_id glyph)
                     invalid_family_ids
                  )
               then "roster-editor-forbidden-glyph"
               else "roster-editor-allowed-glyph"
            )
         ),
         (Html.Events.onClick
            (Struct.Event.SelectedGlyph
               (BattleCharacters.Struct.Glyph.get_id glyph)
            )
         )
      ]
      [
         (Html.text (BattleCharacters.Struct.Glyph.get_name glyph)),
         (Battle.View.Omnimods.get_signed_html
            (Battle.Struct.Omnimods.scale
               factor
               (BattleCharacters.Struct.Glyph.get_omnimods glyph)
            )
         )
      ]
   )

true_get_html : (
      (Maybe Struct.Character.Type) ->
      Int ->
      BattleCharacters.Struct.DataSet.Type ->
      (Html.Html Struct.Event.Type)
   )
true_get_html maybe_char glyph_modifier dataset =
   case maybe_char of
      Nothing -> (Util.Html.nothing)
      (Just char) ->
         (Html.div
            [
               (Html.Attributes.class "selection-window"),
               (Html.Attributes.class "glyph-management")
            ]
            (
               let
                  glyph_multiplier =
                     ((toFloat glyph_modifier) / 100.0)
                  used_glyph_family_indices =
                     (Struct.Character.get_all_glyph_family_indices char)
               in
                  [
                     (Html.text "Glyph Selection"),
                     (Html.div
                        [
                           (Html.Attributes.class "selection-window-listing")
                        ]
                        (List.map
                           (get_glyph_html
                              used_glyph_family_indices
                              glyph_multiplier
                           )
                           (Dict.values
                              (BattleCharacters.Struct.DataSet.get_glyphs
                                 dataset
                              )
                           )
                        )
                     )
                  ]
            )
         )

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
get_html : Struct.Model.Type -> (Html.Html Struct.Event.Type)
get_html model =
   let (slot_index, glyph_modifier) = (Struct.UI.get_glyph_slot model.ui) in
      (Html.Lazy.lazy3
         (true_get_html)
         model.edited_char
         glyph_modifier
         model.characters_dataset
      )
