# Package

version       = "0.1.0"
author        = "Zachary Carter"
description   = "SSG for Karax"
license       = "MIT"

bin = @["zax"]
srcDir = "src"

# Dependencies

requires "nim >= 0.17.1"
requires "docopt >= 0.6.5"
requires "zip >= 0.1.1"