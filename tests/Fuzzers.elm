module Fuzzers exposing (..)

import Fuzz
import Cloudinary


settings : Fuzz.Fuzzer Cloudinary.Settings
settings =
  Fuzz.map4
    (\username apiKey timestamp signature ->
      { username = username
      , apiKey = apiKey
      , timestamp = timestamp
      , signature = signature
      }) Fuzz.string Fuzz.string Fuzz.int Fuzz.string

settingsAndId : Fuzz.Fuzzer { settings : Cloudinary.Settings, id : String }
settingsAndId =
  Fuzz.map2
    (\settings id ->
      { settings = settings
      , id = id
      }) settings Fuzz.string
