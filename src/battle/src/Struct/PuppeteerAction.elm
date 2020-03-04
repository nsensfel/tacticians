module Struct.PuppeteerAction exposing
   (
      Type(..),
      Effect(..),
      from_turn_result
   )

-- Elm -------------------------------------------------------------------------
import Array
import Set

-- Battle Map ------------------------------------------------------------------
import BattleMap.Struct.DataSet
import BattleMap.Struct.Direction

-- Local Module ----------------------------------------------------------------
import Struct.Attack
import Struct.Battle
import Struct.TurnResult

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------
type Effect =
   AnnounceLoss Int
   | AnnounceVictory Int
   | Focus Int
   | Hit Struct.Attack.Type
   | Move (Int, BattleMap.Struct.Direction.Type)
   | RefreshCharacter (Bool, Int)
   | RefreshCharactersOf (Bool, Int)
   | StartTurn Int
   | SwapWeapons Int
   | Target (Int, Int)

type Type =
   Perform (List Effect)
   | PerformFor (Float, (List Effect))

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
from_attacked : Struct.TurnResult.Attack -> (List Type)
from_attacked attack =
   let
      attacker_ix = (Struct.TurnResult.get_attack_actor_index attack)
      defender_ix = (Struct.TurnResult.get_attack_target_index attack)
   in
      (
         [
            (Perform
               [
                  (RefreshCharacter (False, attacker_ix)),
                  (RefreshCharacter (False, defender_ix))
               ]
            ),
            (PerformFor (2.0, [(Focus attacker_ix)])),
            (PerformFor (2.0, [(Focus defender_ix)]))
         ]
         ++
         (List.map
            (\hit->
               (PerformFor (5.0, [(Hit hit)]))
            )
            (Struct.TurnResult.get_attack_sequence attack)
         )
         ++
         [
            (Perform
               [
                  (RefreshCharacter (True, attacker_ix)),
                  (RefreshCharacter (True, defender_ix))
               ]
            )
         ]
      )

from_moved : Struct.TurnResult.Movement -> (List Type)
from_moved movement =
   let actor_ix = (Struct.TurnResult.get_movement_actor_index movement) in
      (
         [
            (PerformFor (1.0, [(Focus actor_ix)])),
            (Perform [(RefreshCharacter (False, actor_ix))])
         ]
         ++
         (List.map
            (\dir ->
               (PerformFor
                  (
                     0.5,
                     [(Move (actor_ix, dir))]
                  )
               )
            )
            (Struct.TurnResult.get_movement_path movement)
         )
         ++
         [ (Perform [(RefreshCharacter (True, actor_ix))]) ]
      )

from_switched_weapon : Struct.TurnResult.WeaponSwitch -> (List Type)
from_switched_weapon weapon_switch =
   let
      actor_ix = (Struct.TurnResult.get_weapon_switch_actor_index weapon_switch)
   in
      [
         (PerformFor (1.0, [(Focus actor_ix)])),
         (PerformFor
            (
               2.0,
               [
                  (RefreshCharacter (False, actor_ix)),
                  (SwapWeapons actor_ix),
                  (RefreshCharacter (True, actor_ix))
               ]
            )
         )
      ]

from_player_won : Struct.TurnResult.PlayerVictory -> (List Type)
from_player_won victory =
   [
      (PerformFor
         (
            2.0,
            [
               (AnnounceVictory
                  (Struct.TurnResult.get_victory_player_index victory)
               )
            ]
         )
      )
   ]

from_player_lost : Struct.TurnResult.PlayerDefeat -> (List Type)
from_player_lost loss =
   let player_ix = (Struct.TurnResult.get_loss_player_index loss) in
      [
         (PerformFor
            (
               2.0,
               [
                  (RefreshCharactersOf (False, player_ix)),
                  (AnnounceLoss player_ix),
                  (RefreshCharactersOf (True, player_ix))
               ]
            )
         )
      ]

from_player_turn_started : Struct.TurnResult.PlayerTurnStart -> (List Type)
from_player_turn_started turn_started =
   let
      player_ix =
         (Struct.TurnResult.get_start_of_turn_player_index turn_started)
   in
      [
         (PerformFor
            (
               2.0,
               [
                  (RefreshCharactersOf (False, player_ix)),
                  (StartTurn player_ix),
                  (RefreshCharactersOf (True, player_ix))
               ]
            )
         )
      ]

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
from_turn_result : Struct.TurnResult.Type -> (List Type)
from_turn_result turn_result =
   case turn_result of
      (Struct.TurnResult.Moved movement) -> (from_moved movement)
      (Struct.TurnResult.Attacked attack) -> (from_attacked attack)
      (Struct.TurnResult.SwitchedWeapon weapon_switch) ->
         (from_switched_weapon weapon_switch)

      (Struct.TurnResult.PlayerWon player_victory) ->
         (from_player_won player_victory)

      (Struct.TurnResult.PlayerLost player_loss) ->
         (from_player_lost player_loss)

      (Struct.TurnResult.PlayerTurnStarted player_turn_start) ->
         (from_player_turn_started player_turn_start)