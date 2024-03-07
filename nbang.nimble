# Package

version       = "0.1.0"
author        = "CarlosEduardoL"
description   = "Nbang is a simple script compiler that allows you to compile and run scripts written in Nim"
license       = "MIT"
srcDir        = "src"
bin           = @["nbang"]


# Dependencies

requires "nim >= 2.0.2"
requires "cligen >= 1"