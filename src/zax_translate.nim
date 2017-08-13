import karax, karaxdsl, vdom

type 
    ContentKind* {.pure.} = enum
      Post

proc translate*(src: string): VNode =
    return buildHtml(h1()):
        text("Hello World!")