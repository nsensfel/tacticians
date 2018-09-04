port module Action.Session exposing (..)

import Struct.Event

port store_new_session : (String, String) -> (Cmd msg)
port reset_session : () -> (Cmd msg)
port connected: (() -> msg) -> (Sub msg)
port go_to : (String) -> (Cmd msg)
