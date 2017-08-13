# Package

version       = "0.1.2"
author        = "Zachary Carter"
description   = "SSG for Karax"
license       = "MIT"

bin = @["zax"]
srcDir = "src"

# Dependencies

requires "nim >= 0.17.1"
requires "docopt >= 0.6.5"
requires "yaml >= 0.10.1"