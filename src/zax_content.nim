import os

type 
  ContentKind* {.pure.} = enum
    Post

template withFile*(f: untyped, filename: string, mode: FileMode,
  body: untyped): typed =
    let fn = filename
    var f: File
    if open(f, fn, mode):
      try:
        body
      finally:
        close(f)
    else:
      discard

iterator posts*(): string =
  for file in walkDirRec("_posts", {pcFile}):
    yield(readFile(file))

proc compile*(content: string, contentKind: ContentKind): string =
  case contentKind
  of ContentKind.Post:
    result = "return buildHtml(tdiv(class=\"posts-container\")):\n" & content