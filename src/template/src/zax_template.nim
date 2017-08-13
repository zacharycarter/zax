import karax, karaxdsl, vdom, zax_translate

proc zax*(contentKind: ContentKind): VNode =
  case contentKind
  of ContentKind.Post:
    # Example of what would be produced by the markdown to karax translator
    var content = translate("foo")
    # Partial gets included here
    include post