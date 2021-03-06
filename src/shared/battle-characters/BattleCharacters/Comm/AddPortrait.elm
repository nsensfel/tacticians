module BattleCharacters.Comm.AddPortrait exposing (decode)

-- Elm -------------------------------------------------------------------------
import Json.Decode

-- Battle Characters -----------------------------------------------------------
import BattleCharacters.Struct.Portrait

-- Local Module ----------------------------------------------------------------
import Struct.ServerReply

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------
internal_decoder : (
      BattleCharacters.Struct.Portrait.Type ->
      Struct.ServerReply.Type
   )
internal_decoder pt = (Struct.ServerReply.AddPortrait pt)

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
decode : (Json.Decode.Decoder Struct.ServerReply.Type)
decode =
   (Json.Decode.map
      (internal_decoder)
      (BattleCharacters.Struct.Portrait.decoder)
   )
