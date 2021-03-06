module Update.SetGlyph exposing (apply_to)

-- Elm -------------------------------------------------------------------------
import Dict

-- Battle Characters -----------------------------------------------------------
import BattleCharacters.Struct.Glyph
import BattleCharacters.Struct.Equipment
import BattleCharacters.Struct.Character

-- Local Module ----------------------------------------------------------------
import Struct.Character
import Struct.Event
import Struct.Model
import Struct.UI

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
apply_to : (
      Struct.Model.Type ->
      BattleCharacters.Struct.Glyph.Ref ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
apply_to model ref =
   (
      (
         case (model.edited_char, (Dict.get ref model.glyphs)) of
            ((Just char), (Just glyph)) ->
               let
                  base_char = (Struct.Character.get_base_character char)
                  (glyph_slot, glyph_modifier) =
                        (Struct.UI.get_glyph_slot model.ui)
                  updated_equipment =
                     (BattleCharacters.Struct.Equipment.set_glyph
                        glyph_slot
                        glyph
                        (BattleCharacters.Struct.Character.get_equipment
                           base_char
                        )
                     )
               in
               {model |
                  edited_char =
                     (Just
                        (Struct.Character.update_glyph_family_index_collections
                           updated_equipment
                           (Struct.Character.set_base_character
                              (BattleCharacters.Struct.Character.set_equipment
                                 updated_equipment
                                 base_char
                              )
                              char
                           )
                        )
                     ),
                  ui =
                     (Struct.UI.set_displayed_tab
                        Struct.UI.GlyphManagementTab
                        model.ui
                     )
               }

            _ -> model
      ),
      Cmd.none
   )
