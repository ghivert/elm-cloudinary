module Cloudinary exposing (CloudinarySettings, uploadPhoto)

{-| This library provides a user friendly interface to upload your photos to Cloudinary.

# Definition
@docs CloudinarySettings

# Upload
@docs uploadPhoto

-}

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Url =
    String


{-| Handle all Cloudinary settings used in upload request to Cloudinary API.
The signature must be produced by the backend, using public API key, and timestamp. It is a SHA1 algorithm, consisting of the string "timestamp=XXXXXXX{APIKEY}", where XXXXXXX is the timestamp, and {APIKEY} is your private API key (which should not be released on your website). Such a signature remains valid one hour after the timestamp.
-}
type alias CloudinarySettings =
    { username : String
    , apiKey : String
    , timestamp : Int
    , signature : String
    }


cloudinaryUrl : String -> String
cloudinaryUrl username =
    "https://api.cloudinary.com/v1_1/" ++ username ++ "/auto/upload"


{-| Upload the photo provided into parameter, and returns it's public ID. At the moment, only the public ID is returned, but it can be improved in a near future.
uploadPhoto accepts any file, encoded in base64. You can get it easily via ports for your uploads.
-}
uploadPhoto : CloudinarySettings -> (Result Http.Error String -> msg) -> String -> Cmd msg
uploadPhoto settings msg_ file =
    Http.send msg_
        <| upload (cloudinaryUrl settings.username) decodeResponse
        <| encodeUploadBody settings.apiKey settings.timestamp settings.signature
        <| file


upload : Url -> Decoder String -> Http.Body -> Http.Request String
upload baseUrl decoder body =
    Http.post baseUrl body decoder


encodeUploadBody : String -> Int -> String -> String -> Http.Body
encodeUploadBody apiKey timestamp signature file =
    Http.jsonBody <|
        Encode.object
            [ ( "file", Encode.string file )
            , ( "api_key", Encode.string apiKey )
            , ( "timestamp", Encode.int timestamp )
            , ( "signature", Encode.string signature )
            ]


decodeResponse : Decoder String
decodeResponse =
    Decode.field "public_id" Decode.string
