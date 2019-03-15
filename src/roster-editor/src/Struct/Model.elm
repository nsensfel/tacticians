module Struct.Model exposing
   (
      Type,
      new,
      add_character_record,
      enable_character_records,
      update_character,
      update_character_fun,
      save_character,
      add_weapon,
      add_armor,
      add_portrait,
      add_glyph,
      add_glyph_board,
      invalidate,
      clear_error
   )

-- Elm -------------------------------------------------------------------------
import Array

import List

import Dict

-- Shared ----------------------------------------------------------------------
import Struct.Flags

import Util.Array

-- Battle Characters -----------------------------------------------------------
import BattleCharacters.Struct.Armor
import BattleCharacters.Struct.Portrait
import BattleCharacters.Struct.Weapon

-- Local Module ----------------------------------------------------------------
import Struct.Character
import Struct.CharacterRecord
import Struct.Error
import Struct.Glyph
import Struct.GlyphBoard
import Struct.HelpRequest
import Struct.Inventory
import Struct.UI

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------
type alias Type =
   {
      flags : Struct.Flags.Type,
      help_request : Struct.HelpRequest.Type,
      characters : (Array.Array Struct.Character.Type),
      stalled_characters : (List Struct.CharacterRecord.Type),
      weapons :
         (Dict.Dict
            BattleCharacters.Struct.Weapon.Ref
            BattleCharacters.Struct.Weapon.Type
         ),
      armors :
         (Dict.Dict
            BattleCharacters.Struct.Armor.Ref
            BattleCharacters.Struct.Armor.Type
         ),
      glyphs : (Dict.Dict Struct.Glyph.Ref Struct.Glyph.Type),
      glyph_boards : (Dict.Dict Struct.GlyphBoard.Ref Struct.GlyphBoard.Type),
      portraits :
         (Dict.Dict
            BattleCharacters.Struct.Portrait.Ref
            BattleCharacters.Struct.Portrait.Type
         ),
      error : (Maybe Struct.Error.Type),
      battle_order : (Array.Array Int),
      player_id : String,
      roster_id : String,
      edited_char : (Maybe Struct.Character.Type),
      inventory : Struct.Inventory.Type,
      session_token : String,
      ui : Struct.UI.Type
   }

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
add_character : Struct.CharacterRecord.Type -> Type -> Type
add_character char_rec model =
   let index = (Struct.CharacterRecord.get_index char_rec) in
      {model |
         characters =
            (Array.push
               (Struct.Character.new
                  index
                  (Struct.CharacterRecord.get_name char_rec)
                  (Dict.get
                     (Struct.CharacterRecord.get_portrait_id char_rec)
                     model.portraits
                  )
                  (Dict.get
                     (Struct.CharacterRecord.get_main_weapon_id char_rec)
                     model.weapons
                  )
                  (Dict.get
                     (Struct.CharacterRecord.get_secondary_weapon_id char_rec)
                     model.weapons
                  )
                  (Dict.get
                     (Struct.CharacterRecord.get_armor_id char_rec)
                     model.armors
                  )
                  (Dict.get
                     (Struct.CharacterRecord.get_glyph_board_id char_rec)
                     model.glyph_boards
                  )
                  (List.map
                     (\e -> (Dict.get e model.glyphs))
                     (Struct.CharacterRecord.get_glyph_ids char_rec)
                  )
               )
               model.characters
            )
      }

has_loaded_data : Type -> Bool
has_loaded_data model =
   (
      ((Array.length model.characters) > 0)
      ||
      (
         (model.portraits /= (Dict.empty))
         && (model.weapons /= (Dict.empty))
         && (model.armors /= (Dict.empty))
         && (model.glyph_boards /= (Dict.empty))
         && (model.glyphs /= (Dict.empty))
      )
   )

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
new : Struct.Flags.Type -> Type
new flags =
   {
      flags = flags,
      help_request = Struct.HelpRequest.None,
      characters = (Array.empty),
      stalled_characters = [],
      weapons = (Dict.empty),
      armors = (Dict.empty),
      glyphs = (Dict.empty),
      glyph_boards = (Dict.empty),
      portraits = (Dict.empty),
      error = Nothing,
      roster_id = "",
      player_id =
         (
            if (flags.user_id == "")
            then "0"
            else flags.user_id
         ),
      battle_order =
         (Array.repeat
            (
               case (Struct.Flags.maybe_get_param "s" flags) of
                  Nothing -> 0
                  (Just "s") -> 8
                  (Just "m") -> 16
                  (Just "l") -> 24
                  (Just _) -> 0
            )
            -1
         ),
      session_token = flags.token,
      edited_char = Nothing,
      inventory = (Struct.Inventory.empty),
      ui = (Struct.UI.default)
   }

add_character_record : Struct.CharacterRecord.Type -> Type -> Type
add_character_record char model =
   if (has_loaded_data model)
   then (add_character char model)
   else {model | stalled_characters = (char :: model.stalled_characters)}

enable_character_records : Type -> Type
enable_character_records model =
   if (has_loaded_data model)
   then
      (List.foldr
         (add_character)
         {model | stalled_characters = []}
         model.stalled_characters
      )
   else
      model

add_weapon : BattleCharacters.Struct.Weapon.Type -> Type -> Type
add_weapon wp model =
   {model |
      weapons =
         (Dict.insert
            (BattleCharacters.Struct.Weapon.get_id wp)
            wp
            model.weapons
         )
   }

add_armor : BattleCharacters.Struct.Armor.Type -> Type -> Type
add_armor ar model =
   {model |
      armors =
         (Dict.insert
            (BattleCharacters.Struct.Armor.get_id ar)
            ar
            model.armors
         )
   }

add_portrait : BattleCharacters.Struct.Portrait.Type -> Type -> Type
add_portrait pt model =
   {model |
      portraits =
         (Dict.insert
            (BattleCharacters.Struct.Portrait.get_id pt)
            pt
            model.portraits
         )
   }

add_glyph : Struct.Glyph.Type -> Type -> Type
add_glyph gl model =
   {model |
      glyphs =
         (Dict.insert
            (Struct.Glyph.get_id gl)
            gl
            model.glyphs
         )
   }

add_glyph_board : Struct.GlyphBoard.Type -> Type -> Type
add_glyph_board glb model =
   {model |
      glyph_boards =
         (Dict.insert
            (Struct.GlyphBoard.get_id glb)
            glb
            model.glyph_boards
         )
   }

update_character : Int -> Struct.Character.Type -> Type -> Type
update_character ix new_val model =
   {model |
      characters = (Array.set ix new_val model.characters)
   }

save_character : Type -> Type
save_character model =
   case model.edited_char of
      Nothing -> model

      (Just char) ->
         {model |
            characters =
               (Array.set
                  (Struct.Character.get_index char)
                  (Struct.Character.set_was_edited True char)
                  model.characters
               )
         }

update_character_fun : (
      Int ->
      ((Maybe Struct.Character.Type) -> (Maybe Struct.Character.Type)) ->
      Type ->
      Type
   )
update_character_fun ix fun model =
   {model |
      characters = (Util.Array.update ix (fun) model.characters)
   }

invalidate : Struct.Error.Type -> Type -> Type
invalidate err model =
   {model |
      error = (Just err)
   }

clear_error : Type -> Type
clear_error model = {model | error = Nothing}
