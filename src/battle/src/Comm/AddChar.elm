module Comm.AddChar exposing (decode)

-- Elm -------------------------------------------------------------------------
import Json.Decode

-- Local Module ----------------------------------------------------------------
import Struct.Character
import Struct.ServerReply

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

internal_decoder : (
      Struct.Character.TypeAndEquipmentRef ->
      Struct.ServerReply.Type
   )
internal_decoder char_and_refs = (Struct.ServerReply.AddCharacter char_and_refs)

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
decode : (Json.Decode.Decoder Struct.ServerReply.Type)
decode = (Json.Decode.map (internal_decoder) (Struct.Character.decoder))
