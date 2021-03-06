import os, osproc, asynchttpserver, asyncdispatch, strutils, httpd, mimetypes, times, sequtils, nre, streams

import zax_content, zax_parser

let doc = """
zax - a static site generator for karax.

Usage:
  zax new <name> [-f | --force]
  zax build
  zax run
  zax create (post) <title>
  zax (-h | --help)

Options:
  -h --help     Show this screen.
  -v --version  Show version.
  -f --force    Force creation of new project.
"""

import docopt

let args = docopt(doc, version = "zax 0.1.0")

const newPostContent = """
---
{
  "layout": "post",
  "title": "$1",
  "date": "$2"
}
---
Hello Zax!
This is pretty cool!
"""

proc isEmpty(directory: string): bool = 
  result = true

  for f in walkDir(directory):
    result = false
    break

proc checkProjectDir(): bool =
  result = true
  if not fileExists("zax.nims"):
    echo "Missing zax.nims! Ensure you are running this command from within a zax project!"
    result = false

proc createNewPost(postTitle: string) =
  if not checkProjectDir():
    quit(QUIT_SUCCESS)
  else:
    const postDir = "./_posts"
    
    if dirExists(postDir):
      setCurrentDir(postDir)
    else:
      createDir(postDir)
      setCurrentDir(postDir)

    var sanitizedTitle = toLowerAscii(postTitle.replace(re"[^a-zA-Z0-9 -]", ""))
    let currentDateTime = getTime().getLocalTime()
    writeFile("$1-$2" % [currentDateTime.format("yyyy-MM-dd"), sanitizedTitle], newPostContent % [postTitle, currentDateTime.format("yyyy-MM-dd HH:mm:ss z")])

proc createNewProject(projectName: string) =
  createDir(projectName)
  copyDir(getAppDir() & DirSep & "template", projectName)
  setCurrentDir(projectName)
  createNewPost("Hello Zax!")

      

proc buildProject() =
  echo "Installing dependencies..."
  echo execProcess("nimble install -y")

  var zax = newFileStream("src/posts.nim", fmWrite)
  zax.setPosition(0)
  zax.write(compile(parsePosts(), ContentKind.Post))
  zax.close()

  echo "Compiling sources..."
  echo execProcess("nim js src/main.nim")

  discard execProcess("open index.html")

proc watchProject() =
  var
    lastWriteTime = 0.Time 
    isRunning = true

  while isRunning:
    for file in walkDirRec(getCurrentDir()):
      # Check for change on .nim file
      var writeTime = 0.Time
      try:
        writeTime = getFileInfo(file).lastWriteTime
      except:
        discard

      if lastWriteTime < writeTime:
        echo "Write detected on " & getCurrentDir()
        buildProject()
        lastWriteTime = getTime()
    
    sleep(20)
        


if args["build"]:
  if not checkProjectDir():
    quit(QUIT_SUCCESS)
  else:
    buildProject()

    quit(QUIT_SUCCESS)

if args["run"]:
  if not checkProjectDir():
    quit(QUIT_SUCCESS)
  else:
    # Loading a DLL needs to be in it's own thread
    var fileWatchingThread: Thread[void]
    createThread(fileWatchingThread, watchProject)

    var settings: NimHttpSettings
    settings.directory = getCurrentDir()
    settings.logging = false
    settings.mimes = newMimeTypes()
    settings.address = ""
    settings.appname = "zax"
    settings.appversion = "0.1.0"
    settings.port = Port(8888)
  
    serve(settings)
    runForever()
    joinThread(fileWatchingThread)

if args["new"]:
  let projectName = $args["<name>"]
  
  if dirExists(projectName):
    if not isEmpty(projectName):
      echo "Project directory already exists and is not empty!"
      if(args["--force"].to_bool):
        createNewProject(projectName)
      else:
        quit(QUIT_SUCCESS)
  else:
    createNewProject(projectName)
      
if args["create"]:
  if args["post"]:
    createNewPost($args["<title>"])