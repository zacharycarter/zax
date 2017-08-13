import karax, karaxdsl, vdom

proc zax*(tag: string): VNode =
  case tag
  of "content":
    # Example of what would be produced by the markdown to karax translator
    var content = buildHtml(h1()):
      text("Hello World!")
    # Partial gets included here
    include post