import vdom, karax, karaxdsl, zax_template, zax_translate

proc createDom(): VNode =
  result = buildHtml(tdiv(class="main")):
    tdiv():
      zax(ContentKind.Post)

setRenderer createDom