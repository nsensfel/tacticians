module BattleMap.Struct.Direction exposing
   (
      Type(..),
      opposite_of,
      to_string,
      decoder
   )

-- Elm -------------------------------------------------------------------------
import Json.Decode

-- Battle Map ------------------------------------------------------------------

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------
type Type =
   None
   | Left
   | Right
   | Up
   | Down

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
from_string : String -> Type
from_string str =
   case str of
      "R" -> Right
      "L" -> Left
      "U" -> Up
      "D" -> Down
      _ -> None

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
opposite_of : Type -> Type
opposite_of d =
   case d of
      Left -> Right
      Right -> Left
      Up -> Down
      Down -> Up
      None -> None

to_string : Type -> String
to_string dir =
   case dir of
      Right -> "R"
      Left -> "L"
      Up -> "U"
      Down -> "D"
      None -> "N"

decoder : (Json.Decode.Decoder Type)
decoder = (Json.Decode.map (from_string) Json.Decode.string)
