module Cloudinary exposing
  ( Settings
  , uploadPhoto
  , toUrl
  )

{-| This library provides a user friendly interface to upload your photos to Cloudinary.

# Definition
@docs Settings

# Upload
@docs uploadPhoto

# Access Uploaded Images
@docs toUrl

-}

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Url =
  String
type alias Id =
  String

{-| Handle all Cloudinary settings used in upload request to Cloudinary API.
The signature must be produced by the backend, using public API key, and timestamp. It is a SHA1 algorithm, consisting of the string "timestamp=XXXXXXX{APIKEY}", where XXXXXXX is the timestamp, and {APIKEY} is your private API key (which should not be released on your website). Such a signature remains valid one hour after the timestamp.
-}
type alias Settings =
  { username : String
  , apiKey : String
  , timestamp : Int
  , signature : String
  }


{-| Upload the photo provided into parameter, and returns it's public ID.
At the moment, only the public ID is returned, but it can be improved in a near future.
uploadPhoto accepts any file, encoded in base64. You can get it easily via ports for your uploads. -}
uploadPhoto : Settings -> (Result Http.Error String -> msg) -> String -> Cmd msg
uploadPhoto ({ username } as settings) msg =
  Http.send msg
    << upload (uploadUrl username) decodeResponse
    << encodeUploadBody settings

upload : Url -> Decoder String -> Http.Body -> Http.Request String
upload baseUrl =
  flip (Http.post baseUrl)

uploadUrl : String -> String
uploadUrl username =
  "https://api.cloudinary.com/v1_1/" ++ username ++ "/auto/upload"

encodeUploadBody : Settings -> String -> Http.Body
encodeUploadBody { apiKey, timestamp, signature } file =
  Http.jsonBody <|
    Encode.object
      [ ( "file", Encode.string file )
      , ( "api_key", Encode.string apiKey )
      , ( "timestamp", Encode.int timestamp )
      , ( "signature", Encode.string signature )
      ]

decodeResponse : Decoder Id
decodeResponse =
  Decode.field "public_id" Decode.string

{-| Access the uploaded photo on Cloudinary servers. Provide the ID to get the
access link. Does not handle transformation on the fly for the moment. -}
toUrl : Settings -> Id -> Url
toUrl { username } id =
  "https://res.cloudinary.com/" ++ username ++ "/image/upload/" ++ id
