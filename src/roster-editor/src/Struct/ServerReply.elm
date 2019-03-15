module Struct.ServerReply exposing (Type(..))

-- Battle Characters -----------------------------------------------------------
import BattleCharacters.Struct.Armor
import BattleCharacters.Struct.Portrait
import BattleCharacters.Struct.Weapon

-- Local Module ----------------------------------------------------------------
import Struct.CharacterRecord
import Struct.Glyph
import Struct.GlyphBoard
import Struct.Inventory

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------

type Type =
   Okay
   | Disconnected
   | GoTo String
   | SetInventory Struct.Inventory.Type
   | AddArmor BattleCharacters.Struct.Armor.Type
   | AddGlyph Struct.Glyph.Type
   | AddGlyphBoard Struct.GlyphBoard.Type
   | AddPortrait BattleCharacters.Struct.Portrait.Type
   | AddWeapon BattleCharacters.Struct.Weapon.Type
   | AddCharacter Struct.CharacterRecord.Type

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
