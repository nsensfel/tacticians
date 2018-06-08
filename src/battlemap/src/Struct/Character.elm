module Struct.Character exposing
   (
      Type,
      Ref,
      get_ref,
      get_player_id,
      get_name,
      get_icon_id,
      get_portrait_id,
      get_armor,
      get_armor_variation,
      get_current_health,
      set_current_health,
      get_location,
      set_location,
      get_attributes,
      get_statistics,
      is_enabled,
      is_alive,
      set_enabled,
      get_weapons,
      set_weapons,
      decoder,
      fill_missing_equipment
   )

-- Elm -------------------------------------------------------------------------
import Json.Decode
import Json.Decode.Pipeline

-- Battlemap -------------------------------------------------------------------
import Struct.Armor
import Struct.Attributes
import Struct.Location
import Struct.Statistics
import Struct.Weapon
import Struct.WeaponSet

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------
type alias PartiallyDecoded =
   {
      ix : Int,
      nam : String,
      ico : String,
      prt : String,
      lc : Struct.Location.Type,
      hea : Int,
      pla : String,
      ena : Bool,
      att : Struct.Attributes.Type,
      awp : Int,
      swp : Int,
      ar : Int
   }

type alias Type =
   {
      id : String,
      name : String,
      icon : String,
      portrait : String,
      location : Struct.Location.Type,
      health : Int,
      player_id : String,
      enabled : Bool,
      attributes : Struct.Attributes.Type,
      statistics : Struct.Statistics.Type,
      weapons : Struct.WeaponSet.Type,
      armor : Struct.Armor.Type
   }

type alias Ref = String

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
finish_decoding : PartiallyDecoded -> (Type, Int, Int, Int)
finish_decoding add_char =
   let
      weapon_set = (Struct.WeaponSet.new Struct.Weapon.none Struct.Weapon.none)
      armor = Struct.Armor.none
      almost_char =
         {
            id = (toString add_char.ix),
            name = add_char.nam,
            icon = add_char.ico,
            portrait = add_char.prt,
            location = add_char.lc,
            health = add_char.hea,
            attributes = add_char.att,
            statistics = (Struct.Statistics.new add_char.att weapon_set armor),
            player_id = add_char.pla,
            enabled = add_char.ena,
            weapons = weapon_set,
            armor = armor
         }
   in
      (almost_char, add_char.awp, add_char.swp, add_char.ar)

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
get_ref : Type -> Ref
get_ref c = c.id

get_name : Type -> String
get_name c = c.name

get_player_id : Type -> String
get_player_id c = c.player_id

get_icon_id : Type -> String
get_icon_id c = c.icon

get_portrait_id : Type -> String
get_portrait_id c = c.portrait

get_current_health : Type -> Int
get_current_health c = c.health

set_current_health : Int -> Type -> Type
set_current_health health c = {c | health = (max 0 health)}

get_location : Type -> Struct.Location.Type
get_location t = t.location

set_location : Struct.Location.Type -> Type -> Type
set_location location char = {char | location = location}

get_attributes : Type -> Struct.Attributes.Type
get_attributes char = char.attributes

get_statistics : Type -> Struct.Statistics.Type
get_statistics char = char.statistics

is_alive : Type -> Bool
is_alive char = (char.health > 0)

is_enabled : Type -> Bool
is_enabled char = char.enabled

set_enabled : Bool -> Type -> Type
set_enabled enabled char = {char | enabled = enabled}

get_weapons : Type -> Struct.WeaponSet.Type
get_weapons char = char.weapons

get_armor : Type -> Struct.Armor.Type
get_armor char = char.armor

get_armor_variation : Type -> String
get_armor_variation char =
   case char.portrait of
      -- Currently hardcoded to match crows from characters.css
      "11" -> "1"
      "4" -> "1"
      _ -> "0"

set_weapons : Struct.WeaponSet.Type -> Type -> Type
set_weapons weapons char =
   {char |
      weapons = weapons,
      statistics = (Struct.Statistics.new char.attributes weapons char.armor)
   }

decoder : (Json.Decode.Decoder (Type, Int, Int, Int))
decoder =
   (Json.Decode.map
      (finish_decoding)
      (Json.Decode.Pipeline.decode
         PartiallyDecoded
         |> (Json.Decode.Pipeline.required "ix" Json.Decode.int)
         |> (Json.Decode.Pipeline.required "nam" Json.Decode.string)
         |> (Json.Decode.Pipeline.required "ico" Json.Decode.string)
         |> (Json.Decode.Pipeline.required "prt" Json.Decode.string)
         |> (Json.Decode.Pipeline.required "lc" (Struct.Location.decoder))
         |> (Json.Decode.Pipeline.required "hea" Json.Decode.int)
         |> (Json.Decode.Pipeline.required "pla" Json.Decode.string)
         |> (Json.Decode.Pipeline.required "ena" Json.Decode.bool)
         |> (Json.Decode.Pipeline.required "att" (Struct.Attributes.decoder))
         |> (Json.Decode.Pipeline.required "awp" Json.Decode.int)
         |> (Json.Decode.Pipeline.required "swp" Json.Decode.int)
         |> (Json.Decode.Pipeline.required "ar" Json.Decode.int)
      )
   )

fill_missing_equipment : (
      Struct.Weapon.Type ->
      Struct.Weapon.Type ->
      Struct.Armor.Type ->
      Type ->
      Type
   )
fill_missing_equipment awp swp ar char =
   let
      weapon_set = (Struct.WeaponSet.new awp swp)
   in
      {char |
         statistics = (Struct.Statistics.new char.attributes weapon_set ar),
         weapons = weapon_set,
         armor = ar
      }
