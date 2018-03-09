module Struct.Attack exposing (Type, Order, Precision)

-- Elm -------------------------------------------------------------------------

-- Battlemap -------------------------------------------------------------------

--------------------------------------------------------------------------------
-- TYPES -----------------------------------------------------------------------
--------------------------------------------------------------------------------
type Order =
   First
   | Counter
   | Second

type Precision =
   Hit
   | Graze
   | Miss

type alias Type =
   {
      order : Order,
      precision : Precision,
      parried : Bool,
      damage : Int
   }

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
