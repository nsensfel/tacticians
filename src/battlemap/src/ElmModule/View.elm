module ElmModule.View exposing (view)

-- Elm -------------------------------------------------------------------------
import Html
import Html.Attributes

-- Battlemap -------------------------------------------------------------------
import Constants.UI

import Struct.Event
import Struct.Model

import View.Battlemap
import View.Controlled
import View.Help
import View.MainMenu
import View.SubMenu

--------------------------------------------------------------------------------
-- LOCAL -----------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- EXPORTED --------------------------------------------------------------------
--------------------------------------------------------------------------------
view : Struct.Model.Type -> (Html.Html Struct.Event.Type)
view model =
   (Html.div
      [
         (Html.Attributes.class "fullscreen-module")
      ]
      [
         (View.MainMenu.get_html model),
         (View.Controlled.get_html model),
         (Html.div
            [
               (Html.Attributes.class "battlemap-container"),
               (Html.Attributes.id Constants.UI.viewer_html_id)
            ]
            [(View.Battlemap.get_html model)]
         ),
         (View.SubMenu.get_html model),
         (View.Help.get_html model)
      ]
   )
