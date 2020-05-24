module BattleMap.Struct.TileInstance exposing
   (
      Type,
      Border,
      clone,
      get_location,
      get_class_id,
      get_family,
      get_cost,
      default,
      set_borders,
      get_borders,
      new_border,
      get_variant_id,
      get_border_variant_id,
      get_border_class_id,
      get_local_variant_ix,
--      remove_status_indicator,
--      add_status_indicator,
--      get_status_indicators,
      remove_tag,
      add_tag,
      get_tags,
      error,
      solve,
      set_location_from_index,
      add_extra_display_effect,
      remove_extra_display_effect,
      get_extra_display_effects,
      get_extra_display_effects_list,
      reset_extra_display_effects,
      decoder,
      encode
   )

-- Elm -------------------------------------------------------------------------
import Dict

import Set

import Json.Encode

import Json.Decode
import Json.Decode.Pipeline

-- Shared ----------------------------------------------------------------------
import Shared.Util.Set

-- Battle Map ------------------------------------------------------------------
import BattleMap.Struct.DataSet
import BattleMap.Struct.Tile
import BattleMap.Struct.Location

-- Local -----------------------------------------------------------------------
import Constants.UI
import Constants.Movement

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------
type alias Type =
   {
      location : BattleMap.Struct.Location.Type,
      crossing_cost : Int,
      family : BattleMap.Struct.Tile.FamilyID,
      class_id : BattleMap.Struct.Tile.Ref,
      variant_id : BattleMap.Struct.Tile.VariantID,
      tags : (Set.Set String),
      extra_display_effects : (Set.Set String),
      borders : (List Border)
   }

type alias Border =
   {
      class_id : BattleMap.Struct.Tile.Ref,
      variant_id : BattleMap.Struct.Tile.VariantID
   }

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
noise_function : Int -> Int -> Int -> Int
noise_function a b c =
   (round (radians (toFloat ((a + 1) * 2 + (b + 1) * 3 + c))))

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
clone : BattleMap.Struct.Location.Type -> Type -> Type
clone loc inst = {inst | location = loc}

new_border : (
      BattleMap.Struct.Tile.Ref ->
      BattleMap.Struct.Tile.VariantID ->
      Border
   )
new_border class_id variant_id =
   {
      class_id = class_id,
      variant_id = variant_id
   }

default : BattleMap.Struct.Tile.Type -> Type
default tile =
   {
      location = {x = 0, y = 0},
      class_id = (BattleMap.Struct.Tile.get_id tile),
      variant_id = "0",
      crossing_cost = (BattleMap.Struct.Tile.get_cost tile),
      family = (BattleMap.Struct.Tile.get_family tile),
      tags = (Set.empty),
      extra_display_effects = (Set.empty),
      borders = []
   }

error : Int -> Int -> Type
error x y =
   {
      location = {x = x, y = y},
      class_id = "0",
      variant_id = "0",
      family = "0",
      crossing_cost = Constants.Movement.cost_when_out_of_bounds,
      tags = (Set.empty),
      extra_display_effects = (Set.empty),
      borders = []
   }

get_class_id : Type -> BattleMap.Struct.Tile.Ref
get_class_id inst = inst.class_id

get_cost : Type -> Int
get_cost inst = inst.crossing_cost

get_location : Type -> BattleMap.Struct.Location.Type
get_location inst = inst.location

get_family : Type -> BattleMap.Struct.Tile.FamilyID
get_family inst = inst.family

set_borders : (List Border) -> Type -> Type
set_borders borders tile_inst = {tile_inst | borders = borders}

get_borders : Type -> (List Border)
get_borders tile_inst = tile_inst.borders

get_variant_id : Type -> BattleMap.Struct.Tile.VariantID
get_variant_id tile_inst = tile_inst.variant_id

get_border_variant_id : Border -> BattleMap.Struct.Tile.VariantID
get_border_variant_id tile_border = tile_border.variant_id

get_local_variant_ix : Type -> Int
get_local_variant_ix tile_inst =
   (modBy
      Constants.UI.local_variants_per_tile
      (noise_function
         tile_inst.location.x
         tile_inst.location.y
         tile_inst.crossing_cost
      )
   )

solve : BattleMap.Struct.DataSet.Type -> Type -> Type
solve dataset tile_inst =
   let tile = (BattleMap.Struct.DataSet.get_tile tile_inst.class_id dataset) in
      {tile_inst |
         crossing_cost = (BattleMap.Struct.Tile.get_cost tile),
         family = (BattleMap.Struct.Tile.get_family tile)
      }

list_to_borders : (
      (List String) ->
      (List Border) ->
      (List Border)
   )
list_to_borders list borders =
   case list of
      (a :: (b :: c)) ->
         (list_to_borders
            c
            ({ class_id = a, variant_id = b } :: borders)
         )
      _ -> (List.reverse borders)

decoder : (Json.Decode.Decoder Type)
decoder =
   (Json.Decode.andThen
      (\tile_data ->
         case tile_data of
            (tile_id :: (variant_id :: borders)) ->
               (Json.Decode.succeed
                  Type
                  |> (Json.Decode.Pipeline.hardcoded {x = 0, y = 0}) -- Location
                  |> (Json.Decode.Pipeline.hardcoded 0) -- Crossing Cost
                  |> (Json.Decode.Pipeline.hardcoded "") -- Family
                  |> (Json.Decode.Pipeline.hardcoded tile_id)
                  |> (Json.Decode.Pipeline.hardcoded variant_id)
                  |> (Json.Decode.Pipeline.hardcoded (Set.empty)) -- tags
                  |> (Json.Decode.Pipeline.hardcoded (Set.empty)) -- display_effects
                  |>
                     (Json.Decode.Pipeline.hardcoded
                        (list_to_borders borders [])
                     )
               )
            _ -> (Json.Decode.succeed (error 0 0))
      )
      (Json.Decode.field "b" (Json.Decode.list (Json.Decode.string)))
   )

get_border_class_id : Border -> BattleMap.Struct.Tile.Ref
get_border_class_id tile_border = tile_border.class_id

set_location_from_index : Int -> Int -> Type -> Type
set_location_from_index map_width index tile_inst =
   {tile_inst |
      location =
            {
               x = (modBy map_width index),
               y = (index // map_width)
            }
   }

encode : Type -> Json.Encode.Value
encode tile_inst =
   (Json.Encode.object
      [
         (
            "b",
            (Json.Encode.list
               (Json.Encode.string)
               (
                  tile_inst.class_id
                  ::
                  (
                     tile_inst.variant_id
                     ::
                     (List.concatMap
                        (\border ->
                           [
                              border.class_id,
                              border.variant_id
                           ]
                        )
                        tile_inst.borders
                     )
                  )
               )
            )
         ),
         (
            "t",
            (Json.Encode.list
               (Json.Encode.string)
               (Set.toList tile_inst.tags)
            )
         )
      ]
   )

get_tags : Type -> (Set.Set String)
get_tags tile_inst = tile_inst.tags

add_tag : String -> Type -> Type
add_tag tag tile_inst =
   {tile_inst |
      tags = (Set.insert tag tile_inst.tags)
   }

remove_tag : String -> Type -> Type
remove_tag tag tile_inst =
   {tile_inst |
      tags = (Set.remove tag tile_inst.tags)
   }

add_extra_display_effect : String -> Type -> Type
add_extra_display_effect effect_name tile =
   {tile |
      extra_display_effects =
         (Set.insert effect_name tile.extra_display_effects)
   }

toggle_extra_display_effect : String -> Type -> Type
toggle_extra_display_effect effect_name tile =
   {tile |
      extra_display_effects =
         (Shared.Util.Set.toggle effect_name tile.extra_display_effects)
   }

remove_extra_display_effect : String -> Type -> Type
remove_extra_display_effect effect_name tile =
   {tile |
      extra_display_effects =
         (Set.remove effect_name tile.extra_display_effects)
   }

get_extra_display_effects : Type -> (Set.Set String)
get_extra_display_effects tile = tile.extra_display_effects

get_extra_display_effects_list : Type -> (List String)
get_extra_display_effects_list tile = (Set.toList tile.extra_display_effects)

reset_extra_display_effects : Type -> Type
reset_extra_display_effects tile = {tile | extra_display_effects = (Set.empty)}
