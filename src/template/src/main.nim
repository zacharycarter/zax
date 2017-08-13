import vdom, karax, karaxdsl, zaxtemp

proc createDom(): VNode =
  result = buildHtml(tdiv(class="main")):
    tdiv():
      zax("content")

setRenderer createDom