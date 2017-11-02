module Error exposing (Type, Mode(..), new, to_string)

type Mode =
   IllegalAction
   | Programming
   | Unimplemented
   | Networking

type alias Type =
   {
      mode: Mode,
      message: String
   }

new : Mode -> String -> Type
new mode str =
   {
      mode = mode,
      message = str
   }

to_string : Type -> String
to_string e =
   (
      (case e.mode of
         IllegalAction -> "Request discarded: "
         Programming -> "Error in the program (please report): "
         Unimplemented -> "Update discarded due to unimplemented feature: "
         Networking -> "Error while conversing with the server: "
      )
      ++ e.message
   )

