module View.Controlled.CharacterCard exposing
   (
      get_minimal_html,
      get_summary_html,
      get_full_html
   )

-- Elm -------------------------------------------------------------------------
import List

import Html
import Html.Attributes
import Html.Events

-- Shared ----------------------------------------------------------------------
import Util.Html

-- Battle ----------------------------------------------------------------------
import Battle.Struct.Omnimods
import Battle.Struct.Statistics

-- Battle Characters -----------------------------------------------------------
import BattleCharacters.Struct.Armor
import BattleCharacters.Struct.Weapon

-- Local Module ----------------------------------------------------------------
import Struct.Character
import Struct.CharacterTurn
import Struct.Event
import Struct.HelpRequest
import Struct.Navigator

import View.Character
import View.Gauge

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
get_name : (
      Struct.Character.Type ->
      (Html.Html Struct.Event.Type)
   )
get_name char =
   (Html.div
      [
         (Html.Attributes.class "info-card-name"),
         (Html.Attributes.class "info-card-text-field"),
         (Html.Attributes.class "character-card-name")
      ]
      [
         (Html.text (Struct.Character.get_name char))
      ]
   )

get_health_bar : (
      Struct.Character.Type ->
      (Html.Html Struct.Event.Type)
   )
get_health_bar char =
   let
      current = (Struct.Character.get_sane_current_health char)
      max =
         (Battle.Struct.Statistics.get_max_health
            (Struct.Character.get_statistics char)
         )
   in
      (View.Gauge.get_html
         ("HP: " ++ (String.fromInt current) ++ "/" ++ (String.fromInt max))
         (100.0 * ((toFloat current)/(toFloat max)))
         [(Html.Attributes.class "character-card-health")]
         []
         []
      )

get_rank_status : Struct.Character.Rank -> (Html.Html Struct.Event.Type)
get_rank_status rank =
   (Html.div
      [
         (Html.Attributes.class "character-card-status"),
         (Html.Attributes.class "clickable"),
         (Html.Events.onClick
            (Struct.Event.RequestedHelp (Struct.HelpRequest.HelpOnRank rank))
         ),
         (Html.Attributes.class
            (
               case rank of
                  Struct.Character.Commander ->
                     "character-card-commander-status"

                  Struct.Character.Target ->
                     "character-card-target-status"

                  Struct.Character.Optional -> ""
            )
         )
      ]
      [
      ]
   )

get_statuses : Struct.Character.Type -> (Html.Html Struct.Event.Type)
get_statuses char =
   (Html.div
      [
         (Html.Attributes.class "character-card-statuses")
      ]
      [
         (
            case (Struct.Character.get_rank char) of
               Struct.Character.Optional -> (Util.Html.nothing)
               other -> (get_rank_status other)
         )
      ]
   )

get_active_movement_bar : (
      (Maybe Struct.Navigator.Type) ->
      Struct.Character.Type ->
      (Html.Html Struct.Event.Type)
   )
get_active_movement_bar maybe_navigator char =
   let
      max =
         (Battle.Struct.Statistics.get_movement_points
            (Struct.Character.get_statistics char)
         )
      current =
         case maybe_navigator of
            (Just navigator) ->
               (Struct.Navigator.get_remaining_points navigator)

            Nothing ->
               max
   in
      (View.Gauge.get_html
         ("MP: " ++ (String.fromInt current) ++ "/" ++ (String.fromInt max))
         (100.0 * ((toFloat current)/(toFloat max)))
         [(Html.Attributes.class "character-card-movement")]
         []
         []
      )

get_inactive_movement_bar : (
      Struct.Character.Type ->
      (Html.Html Struct.Event.Type)
   )
get_inactive_movement_bar char =
   let
      max =
         (Battle.Struct.Statistics.get_movement_points
            (Struct.Character.get_statistics char)
         )
   in
      (View.Gauge.get_html
         (
            "MP: "
            ++
            (String.fromInt
               (Battle.Struct.Statistics.get_movement_points
                  (Struct.Character.get_statistics char)
               )
            )
         )
         100.0
         [(Html.Attributes.class "character-card-movement")]
         []
         []
      )

get_movement_bar : (
      Struct.CharacterTurn.Type ->
      Struct.Character.Type ->
      (Html.Html Struct.Event.Type)
   )
get_movement_bar char_turn char =
   case (Struct.CharacterTurn.try_getting_active_character char_turn) of
      (Just active_char) ->
         if
         (
            (Struct.Character.get_index active_char)
            ==
            (Struct.Character.get_index char)
         )
         then
            (get_active_movement_bar
               (Struct.CharacterTurn.try_getting_navigator char_turn)
               active_char
            )
         else
            (get_inactive_movement_bar char)

      Nothing ->
         (get_inactive_movement_bar char)

get_weapon_field_header : (
      Float ->
      BattleCharacters.Struct.Weapon.Type ->
      (Html.Html Struct.Event.Type)
   )
get_weapon_field_header damage_multiplier weapon =
   (Html.div
      [
         (Html.Attributes.class "character-card-header")
      ]
      [
         (Html.div
            [
            ]
            [
               (Html.text (BattleCharacters.Struct.Weapon.get_name weapon))
            ]
         ),
         (Html.div
            [
            ]
            [
               (Html.text
                  (
                     "~"
                     ++
                     (String.fromInt
                        (ceiling
                           (
                              (toFloat
                                 (BattleCharacters.Struct.Weapon.get_damage_sum
                                    weapon
                                 )
                              )
                              * damage_multiplier
                           )
                        )
                     )
                     ++ " dmg @ ["
                     ++
                     (String.fromInt
                        (BattleCharacters.Struct.Weapon.get_defense_range
                           weapon
                        )
                     )
                     ++ ", "
                     ++
                     (String.fromInt
                        (BattleCharacters.Struct.Weapon.get_attack_range
                           weapon
                        )
                     )
                     ++ "]"
                  )
               )
            ]
         )
      ]
   )

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

get_multiplied_mod_html : Float -> (String, Int) -> (Html.Html Struct.Event.Type)
get_multiplied_mod_html multiplier mod =
   let (category, value) = mod in
      (Html.div
         [
            (Html.Attributes.class "character-card-mod")
         ]
         [
            (Html.div
               [
                  (Html.Attributes.class "omnimod-icon"),
                  (Html.Attributes.class ("omnimod-icon-" ++ category))
               ]
               [
               ]
            ),
            (Html.text
               (String.fromInt (ceiling ((toFloat value) * multiplier)))
            )
         ]
      )

get_weapon_details : (
      Battle.Struct.Omnimods.Type ->
      Float ->
      BattleCharacters.Struct.Weapon.Type ->
      (Html.Html Struct.Event.Type)
   )
get_weapon_details omnimods damage_multiplier weapon =
   (Html.div
      [
         (Html.Attributes.class "character-card-weapon")
      ]
      [
         (get_weapon_field_header damage_multiplier weapon),
         (Html.div
            [
               (Html.Attributes.class "info-card-omnimods-listing")
            ]
            (List.map
               (get_multiplied_mod_html damage_multiplier)
               (Battle.Struct.Omnimods.get_attack_mods omnimods)
            )
         )
      ]
   )

get_weapon_summary : (
      Float ->
      BattleCharacters.Struct.Weapon.Type ->
      (Html.Html Struct.Event.Type)
   )
get_weapon_summary damage_multiplier weapon =
   (Html.div
      [
         (Html.Attributes.class "character-card-weapon-summary")
      ]
      [
         (get_weapon_field_header damage_multiplier weapon)
      ]
   )

get_armor_details : (
      Battle.Struct.Omnimods.Type ->
      BattleCharacters.Struct.Armor.Type ->
      (Html.Html Struct.Event.Type)
   )
get_armor_details omnimods armor =
   (Html.div
      [
         (Html.Attributes.class "character-card-armor")
      ]
      [
         (Html.div
            [
               (Html.Attributes.class "character-card-armor-name")
            ]
            [
               (Html.text (BattleCharacters.Struct.Armor.get_name armor))
            ]
         ),
         (Html.div
            [
               (Html.Attributes.class "info-card-omnimods-listing")
            ]
            (List.map
               (get_mod_html)
               (Battle.Struct.Omnimods.get_defense_mods omnimods)
            )
         )
      ]
   )

stat_name : String -> (Html.Html Struct.Event.Type)
stat_name name =
   (Html.div
      [
         (Html.Attributes.class "character-card-stat-name")
      ]
      [
         (Html.text name)
      ]
   )

stat_val : Int -> Bool -> (Html.Html Struct.Event.Type)
stat_val val perc =
   (Html.div
      [
         (Html.Attributes.class "character-card-stat-val")
      ]
      [
         (Html.text
            (
               (String.fromInt val)
               ++
               (if perc then "%" else "")
            )
         )
      ]
   )

get_relevant_stats : (
      Battle.Struct.Statistics.Type ->
      (Html.Html Struct.Event.Type)
   )
get_relevant_stats stats =
   (Html.div
      [
         (Html.Attributes.class "character-card-stats")
      ]
      [
         (stat_name "Dodge"),
         (stat_val (Battle.Struct.Statistics.get_dodges stats) True),
         (stat_name "Parry"),
         (stat_val (Battle.Struct.Statistics.get_parries stats) True),
         (stat_name "Accu."),
         (stat_val (Battle.Struct.Statistics.get_accuracy stats) False),
         (stat_name "2xHit"),
         (stat_val (Battle.Struct.Statistics.get_double_hits stats) True),
         (stat_name "Crit."),
         (stat_val (Battle.Struct.Statistics.get_critical_hits stats) True)
      ]
   )

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
get_minimal_html : (
      Int ->
      Struct.Character.Type ->
      (Html.Html Struct.Event.Type)
   )
get_minimal_html player_ix char =
   (Html.div
      [
         (Html.Attributes.class "info-card"),
         (Html.Attributes.class "info-card-minimal"),
         (Html.Attributes.class "character-card"),
         (Html.Attributes.class "character-card-minimal")
      ]
      [
         (get_name char),
         (Html.div
            [
               (Html.Attributes.class "info-card-top"),
               (Html.Attributes.class "character-card-top")
            ]
            [
               (Html.div
                  [
                     (Html.Attributes.class "info-card-picture")
                  ]
                  [
                     (View.Character.get_portrait_html player_ix char)
                  ]
               ),
               (get_health_bar char),
               (get_inactive_movement_bar char),
               (get_statuses char)
            ]
         )
      ]
   )

get_summary_html : (
      Struct.CharacterTurn.Type ->
      Int ->
      Struct.Character.Type ->
      (Html.Html Struct.Event.Type)
   )
get_summary_html char_turn player_ix char =
   let
      is_using_primary = (Struct.Character.get_is_using_primary char)
      active_weapon =
         (
            if (is_using_primary)
            then (Struct.Character.get_primary_weapon char)
            else (Struct.Character.get_secondary_weapon char)
         )
      inactive_weapon =
         (
            if (is_using_primary)
            then (Struct.Character.get_secondary_weapon char)
            else (Struct.Character.get_primary_weapon char)
         )
      char_statistics = (Struct.Character.get_statistics char)
      damage_modifier =
         (Battle.Struct.Statistics.get_damage_modifier char_statistics)
      omnimods = (Struct.Character.get_current_omnimods char)
   in
      (Html.div
         [
            (Html.Attributes.class "character-card")
         ]
         [
            (get_name char),
            (Html.div
               [
                  (Html.Attributes.class "info-card-top"),
                  (Html.Attributes.class "character-card-top")
               ]
               [
                  (Html.div
                     [
                        (Html.Attributes.class "info-card-picture")
                     ]
                     [
                        (View.Character.get_portrait_html player_ix char)
                     ]
                  ),
                  (get_health_bar char),
                  (get_movement_bar char_turn char),
                  (get_statuses char)
               ]
            ),
            (get_weapon_details omnimods damage_modifier active_weapon),
            (get_armor_details omnimods (Struct.Character.get_armor char)),
            (get_relevant_stats char_statistics),
            (get_weapon_summary damage_modifier inactive_weapon)
         ]
      )

get_full_html : (
      Int ->
      Struct.Character.Type ->
      (Html.Html Struct.Event.Type)
   )
get_full_html player_ix char =
   let
      is_using_primary = (Struct.Character.get_is_using_primary char)
      active_weapon =
         (
            if (is_using_primary)
            then (Struct.Character.get_primary_weapon char)
            else (Struct.Character.get_secondary_weapon char)
         )
      inactive_weapon =
         (
            if (is_using_primary)
            then (Struct.Character.get_secondary_weapon char)
            else (Struct.Character.get_primary_weapon char)
         )
      char_statistics = (Struct.Character.get_statistics char)
      damage_modifier =
         (Battle.Struct.Statistics.get_damage_modifier char_statistics)
      omnimods = (Struct.Character.get_current_omnimods char)
      armor = (Struct.Character.get_armor char)
   in
      (Html.div
         [
            (Html.Attributes.class "info-card"),
            (Html.Attributes.class "character-card")
         ]
         [
            (get_name char),
            (Html.div
               [
                  (Html.Attributes.class "info-card-top"),
                  (Html.Attributes.class "character-card-top")
               ]
               [
                  (Html.div
                     [
                        (Html.Attributes.class "info-card-picture")
                     ]
                     [
                        (View.Character.get_portrait_html player_ix char)
                     ]
                  ),
                  (get_health_bar char),
                  (get_inactive_movement_bar char),
                  (get_statuses char)
               ]
            ),
            (get_weapon_details omnimods damage_modifier active_weapon),
            (get_armor_details omnimods armor),
            (get_relevant_stats char_statistics),
            (get_weapon_summary damage_modifier inactive_weapon)
         ]
      )
