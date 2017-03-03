module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzzers
import Cloudinary


all : Test
all =
  describe "Test Cloudinary API"
    [ fuzz Fuzzers.settingsAndId "toUrl"
      <| \params ->
        Expect.equal
          (Cloudinary.toUrl params.settings params.id)
          ("http://res.cloudinary.com/" ++ params.settings.username ++ "/image/upload/" ++ params.id)
    ]
