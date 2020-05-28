module ElmModule.Update exposing (update)

-- Elm -------------------------------------------------------------------------

-- Shared ----------------------------------------------------------------------
import Shared.Update.Sequence

-- Local Module ----------------------------------------------------------------
import Struct.Event
import Struct.Model

import Update.HandleServerReply
import Update.Puppeteer
import Update.SelectCharacter
import Update.SelectCharacterOrTile
import Update.SelectTile
import Update.SetRequestedHelp

import Update.Puppeteer.Play
import Update.Puppeteer.TogglePause
import Update.Puppeteer.SkipTo

import Update.Character.ScrollTo
import Update.Character.DisplayNavigator

import Update.CharacterTurn.AbortTurn
import Update.CharacterTurn.Attack
import Update.CharacterTurn.EndTurn
import Update.CharacterTurn.Move
import Update.CharacterTurn.RequestDirection
import Update.CharacterTurn.Skill
import Update.CharacterTurn.Skip
import Update.CharacterTurn.SwitchWeapon
import Update.CharacterTurn.UndoAction

import Update.UI.ChangeScale
import Update.UI.GoToMainMenu
import Update.UI.SelectTab

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
update : (
      Struct.Event.Type ->
      Struct.Model.Type ->
      (Struct.Model.Type, (Cmd Struct.Event.Type))
   )
update event model =
   case event of
      Struct.Event.None -> (model, Cmd.none)

      (Struct.Event.Failed err) ->
         (
            (Struct.Model.invalidate err model),
            Cmd.none
         )

      Struct.Event.AttackRequest ->
         (Update.CharacterTurn.Attack.apply_to model)

      Struct.Event.SkillRequest ->
         (Update.CharacterTurn.Skill.apply_to model)

      Struct.Event.SkipRequest ->
         (Update.CharacterTurn.Skip.apply_to model)

      Struct.Event.MoveRequest ->
         (Update.CharacterTurn.Move.apply_to model)

      Struct.Event.AnimationEnded ->
         (Update.Puppeteer.apply_to model)

      (Struct.Event.PuppeteerPlay forward) ->
         (Update.Puppeteer.Play.apply_to forward model)

      (Struct.Event.PuppeteerSkipTo forward) ->
         (Update.Puppeteer.SkipTo.apply_to forward model)

      Struct.Event.PuppeteerTogglePause ->
         (Update.Puppeteer.TogglePause.apply_to model)

      (Struct.Event.DirectionRequested d) ->
         (Update.CharacterTurn.RequestDirection.apply_to d model)

      (Struct.Event.TileSelected loc) ->
         (Update.SelectTile.apply_to loc model)

      (Struct.Event.CharacterOrTileSelected loc) ->
         (Update.SelectCharacterOrTile.apply_to loc model)

      (Struct.Event.CharacterSelected char_id) ->
         (Update.SelectCharacter.apply_to char_id model)

      (Struct.Event.CharacterCardSelected char_id) ->
         (Shared.Update.Sequence.sequence
            [
               (Update.Character.ScrollTo.apply_to_ref char_id),
               (Update.Character.DisplayNavigator.apply_to_ref char_id)
            ]
            model
         )

      Struct.Event.TurnEnded ->
         (Update.CharacterTurn.EndTurn.apply_to model)

      (Struct.Event.ScaleChangeRequested mod) ->
         (Update.UI.ChangeScale.apply_to mod model)

      (Struct.Event.TabSelected tab) ->
         (Update.UI.SelectTab.apply_to tab model)

      (Struct.Event.ServerReplied result) ->
         (Update.HandleServerReply.apply_to result model)

      Struct.Event.WeaponSwitchRequest ->
         (Update.CharacterTurn.SwitchWeapon.apply_to model)

      Struct.Event.AbortTurnRequest ->
         (Update.CharacterTurn.AbortTurn.apply_to model)

      Struct.Event.UndoActionRequest ->
         (Update.CharacterTurn.UndoAction.apply_to model)

      (Struct.Event.RequestedHelp help_request) ->
         (Update.SetRequestedHelp.apply_to help_request model)

      Struct.Event.GoToMainMenu ->
         (Update.UI.GoToMainMenu.apply_to model)
