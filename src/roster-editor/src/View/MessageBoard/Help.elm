module View.MessageBoard.Help exposing (get_html)

-- Elm -------------------------------------------------------------------------
import Html
import Html.Attributes

-- Battle ----------------------------------------------------------------------
import Battle.View.Help.Attribute
import Battle.View.Help.Statistic

-- Local Module ----------------------------------------------------------------
import Struct.Event
import Struct.HelpRequest
import Struct.Model

import View.MessageBoard.Help.Guide

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
get_html : Struct.Model.Type -> (Html.Html Struct.Event.Type)
get_html model =
   (Html.div
      [
         (Html.Attributes.class "message-board"),
         (Html.Attributes.class "message-board-help")
      ]
      (
         case model.help_request of
            Struct.HelpRequest.None ->
               (View.MessageBoard.Help.Guide.get_html_contents model)

            (Struct.HelpRequest.Attribute att_cat) ->
               (Battle.View.Help.Attribute.get_html_contents att_cat)

            (Struct.HelpRequest.Statistic stat_cat) ->
               (Battle.View.Help.Statistic.get_html_contents stat_cat)

            _ -> (View.MessageBoard.Help.Guide.get_html_contents model)
      )
   )
