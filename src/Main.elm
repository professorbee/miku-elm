module Main exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, string)
main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

type Model
  = Failure
  | Loading
  | Success String

init : () -> (Model, Cmd Msg)
init _ =
  (Loading, getRandomMikuGif)

type Msg
  = MorePlease
  | GotGif (Result Http.Error String)

update : Msg -> Model -> (Model, Cmd Msg)
update msg _ =
  case msg of
    MorePlease ->
      (Loading, getRandomMikuGif)

    GotGif result ->
      case result of
        Ok url ->
          (Success url, Cmd.none)

        Err _ ->
          (Failure, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none

view : Model -> Html Msg
view model =
  div []
    [ viewGif model ]

viewGif : Model -> Html Msg
viewGif model =
  case model of
    Failure ->
      div []
        [ text "I could not load a random miku for some reason. "
        , button [ onClick MorePlease ] [ text "Try Again!" ]
        ]

    Loading ->
      text "Loading..."

    Success url ->
      div []
        [ img [ src url, alt "Miku." ] [],
        div [ class "text-center"] [button [ onClick MorePlease] [ text "More Please!" ]]
        ]

getRandomMikuGif : Cmd Msg
getRandomMikuGif =
  Http.get
    { url = "https://plushmiku.xyz/api/random"
    , expect = Http.expectJson GotGif gifDecoder
    }

gifDecoder : Decoder String
gifDecoder =
  field "username" string