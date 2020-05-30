module View.SubMenu.Timeline.Attack exposing (get_html)

-- Elm -------------------------------------------------------------------------
import Array

import Html
import Html.Attributes

-- Battle Characters -----------------------------------------------------------
import BattleCharacters.Struct.Character

-- Local Module ----------------------------------------------------------------
import Struct.Attack
import Struct.Event
import Struct.Character

import View.Character

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
get_title_html : (
      Struct.Character.Type ->
      Struct.Character.Type ->
      (Html.Html Struct.Event.Type)
   )
get_title_html attacker defender =
   (Html.div
      [
         (Html.Attributes.class "timeline-attack-title")
      ]
      [
         (Html.text
            (
               (BattleCharacters.Struct.Character.get_name
                  (Struct.Character.get_base_character attacker)
               )
               ++ " attacked "
               ++
               (BattleCharacters.Struct.Character.get_name
                  (Struct.Character.get_base_character defender)
               )
               ++ "!"
            )
         )
      ]
   )

get_effect_text : Struct.Attack.Type -> String
get_effect_text attack =
   let precision = (Struct.Attack.get_precision attack) in
   (
      (
         case precision of
            Struct.Attack.Hit -> " hit for "
            Struct.Attack.Graze -> " grazed for "
            Struct.Attack.Miss -> " missed."
      )
      ++
      (
         if (precision == Struct.Attack.Miss)
         then
            ""
         else
            (
               ((String.fromInt (Struct.Attack.get_damage attack)) ++ " damage")
               ++
               (
                  if (Struct.Attack.get_is_a_critical attack)
                  then " (Critical Hit)."
                  else "."
               )
            )
      )
   )

get_attack_html : (
      Struct.Character.Type ->
      Struct.Character.Type ->
      Struct.Attack.Type ->
      (Html.Html Struct.Event.Type)
   )
get_attack_html attacker defender attack =
   let
      attacker_name =
         (BattleCharacters.Struct.Character.get_name
            (Struct.Character.get_base_character attacker)
         )
      defender_name =
         (BattleCharacters.Struct.Character.get_name
            (Struct.Character.get_base_character defender)
         )
   in
   (Html.div
      []
      [
         (Html.text
            (
               case
                  (
                     (Struct.Attack.get_order attack),
                     (Struct.Attack.get_is_a_parry attack)
                  )
               of
                  (Struct.Attack.Counter, True) ->
                     (
                        defender_name
                        ++ " attempted to strike back, but "
                        ++ attacker_name
                        ++ " parried, and "
                        ++ (get_effect_text attack)
                     )

                  (Struct.Attack.Counter, _) ->
                     (
                        attacker_name
                        ++ " striked back, and "
                        ++ (get_effect_text attack)
                     )

                  (_, True) ->
                     (
                        defender_name
                        ++ " attempted a hit, but "
                        ++ attacker_name
                        ++ " parried, and "
                        ++ (get_effect_text attack)
                     )

                  (_, _) ->
                     (attacker_name ++ " " ++ (get_effect_text attack))
            )
         )
      ]
   )

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
get_html : (
      (Array.Array Struct.Character.Type) ->
      Int ->
      Struct.Attack.Type ->
      (Html.Html Struct.Event.Type)
   )
get_html characters player_ix attack =
   case
      (
         (Array.get (Struct.Attack.get_actor_index attack) characters),
         (Array.get (Struct.Attack.get_target_index attack) characters)
      )
   of
      ((Just atkchar), (Just defchar)) ->
         (Html.div
            [
               (Html.Attributes.class "timeline-element"),
               (Html.Attributes.class "timeline-attack")
            ]
            [
               (View.Character.get_portrait_html atkchar),
               (View.Character.get_portrait_html defchar),
               (get_title_html atkchar defchar),
               (get_attack_html
                  atkchar
                  defchar
                  attack
               )
            ]
         )

      _ ->
         (Html.div
            [
               (Html.Attributes.class "timeline-element"),
               (Html.Attributes.class "timeline-attack")
            ]
            [
               (Html.text "Error: Attack with unknown characters")
            ]
         )
