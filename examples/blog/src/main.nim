import vdom, karax, karaxdsl

proc createDom(): VNode =
  result = buildHtml(tdiv(class="main"))

setRenderer createDom