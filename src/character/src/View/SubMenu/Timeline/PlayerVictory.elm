module View.SubMenu.Timeline.PlayerVictory exposing (get_html)

-- Elm -------------------------------------------------------------------------
import Html
import Html.Attributes
--import Html.Events

-- Map -------------------------------------------------------------------
import Struct.Event
import Struct.TurnResult

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
get_html : (
      Struct.TurnResult.PlayerVictory ->
      (Html.Html Struct.Event.Type)
   )
get_html pvict =
   (Html.div
      [
         (Html.Attributes.class "battle-timeline-element"),
         (Html.Attributes.class "battle-timeline-player-victory")
      ]
      [
         (Html.text
            (
               "Player "
               ++ (toString pvict.player_index)
               ++ " has won the map."
            )
         )
      ]
   )
