import os, osproc, asynchttpserver, asyncdispatch, strutils, httpd, mimetypes, times

let doc = """
zax - a static site generator for karax.

Usage:
  zax new <name> [-f | --force]
  zax build
  zax run
  zax (-h | --help)

Options:
  -h --help     Show this screen.
  -v --version  Show version.
  -f --force    Force creation of new project.
"""

import docopt

let args = docopt(doc, version = "zax 0.1.0")

proc isEmpty(directory: string): bool = 
  result = true

  for f in walkDir(directory):
    result = false
    break

proc createNewProject(projectName: string) =
  createDir(projectName)
  copyDir("template", projectName)

proc checkProjectDir(): bool =
  result = true
  if not fileExists("zax.nims"):
    echo "Missing zax.nims! Ensure you are running this command from within a zax project!"
    result = false

proc buildProject() =
  echo "Installing dependencies..."
  echo execProcess("nimble install -y")
  
  echo "Compiling sources..."
  echo execProcess("nim js src/main.nim")

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
        lastWriteTime = writeTime
        buildProject()

    sleep(200)


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
      
