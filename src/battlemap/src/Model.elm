module Model exposing
   (
      Type,
      State(..),
      add_character,
      get_state,
      invalidate,
      reset,
      clear_error
   )

-- Elm -------------------------------------------------------------------------
import Dict

-- Battlemap -------------------------------------------------------------------
import Battlemap
import Battlemap.Location

import UI

import Error

import Character

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------
type State =
   Default
   | ControllingCharacter Character.Ref
   | InspectingTile Battlemap.Location.Ref
   | InspectingCharacter Character.Ref

type alias Type =
   {
      state: State,
      battlemap: Battlemap.Type,
      characters: (Dict.Dict Character.Ref Character.Type),
      error: (Maybe Error.Type),
      controlled_team: Int,
      ui: UI.Type
   }

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
add_character : Type -> Character.Type -> Type
add_character model char =
   {model |
      characters =
         (Dict.insert
            (Character.get_ref char)
            char
            model.characters
         )
   }

get_state : Type -> State
get_state model = model.state

reset : Type -> (Dict.Dict Character.Ref Character.Type) -> Type
reset model characters =
   {model |
      state = Default,
      battlemap = (Battlemap.reset model.battlemap),
      characters = characters,
      error = Nothing,
      ui = (UI.set_previous_action model.ui Nothing)
   }

invalidate : Type -> Error.Type -> Type
invalidate model err =
   {model |
      error = (Just err),
      ui = (UI.set_displayed_tab model.ui UI.StatusTab)
   }

clear_error : Type -> Type
clear_error model = {model | error = Nothing}
