module Update.SetArmor exposing (apply_to)

-- Elm -------------------------------------------------------------------------
import Dict

-- Battle Characters -----------------------------------------------------------
import BattleCharacters.Struct.Armor
import BattleCharacters.Struct.Character
import BattleCharacters.Struct.DataSet
import BattleCharacters.Struct.Equipment

-- Local Module ----------------------------------------------------------------
import Struct.Character
import Struct.Event
import Struct.Model

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
equip : (
      BattleCharacters.Struct.Armor.Type ->
      Struct.Character.Type ->
      Struct.Character.Type
   )
equip armor char =
   let base_char = (Struct.Character.get_base_character char) in
      (Struct.Character.set_is_valid
         (Struct.Character.set_base_character
            (BattleCharacters.Struct.Character.set_equipment
               (BattleCharacters.Struct.Equipment.set_armor
                  armor
                  (BattleCharacters.Struct.Character.get_equipment
                     base_char
                  )
               )
               base_char
            )
            char
         )
      )

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
apply_to : (
      Struct.Model.Type ->
      BattleCharacters.Struct.Armor.Ref ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
apply_to model armor_id =
   (
      (
         case model.edited_char of
            (Just char) ->
               {model |
                  edited_char =
                     (Just
                        (equip
                           (BattleCharacters.Struct.DataSet.get_armor
                              armor_id
                              model.characters_dataset
                           )
                           char
                        )
                     )
               }

            _ -> model
      ),
      Cmd.none
   )
