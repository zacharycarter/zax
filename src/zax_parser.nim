import zax_content, strutils, nre, json, os

type
  FrontMatter = object
    title: string
    layout: string
    date: string

proc parsePosts*(): string =
  result = ""
  for post in posts():
    var p: string
    let splitPost = post.split(re"---")
    let frontMatterText = splitPost[1]
    let content = splitPost[2]
    
    let frontMatter = to(parseJson(frontMatterText), FrontMatter)

    let templateFile = "src/$1.nim" % frontMatter.layout 
    if not fileExists(templateFile):
      return
    
    let temp = readFile(templateFile)
    for capture in temp.find(re"{{(.*)}}").get.captures:
      case capture
      of "content":
        p = temp.replace("{{content}}", "text(\"\"\"$1\"\"\")" % strip(content) & " \n")

    result &= indent(p, 4)