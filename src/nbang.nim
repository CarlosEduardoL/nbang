import os, strformat, times, strutils, osproc, json, hashes

type
  ScriptInfo = object
    hash: string
    compilation_arguments: string
  ScriptMetaInfo = object
    name: string
    script_path: string
    compiled_path: string
    compilation_arguments: string
    arguments: seq[string]

## Directory to keep compiled scripts
let cache_dir = getHomeDir() / ".nbang"

proc script_path*(script: string): string =
  result = cache_dir / script
  if not dirExists(result):
    try:
      createDir(result)
    except IOError as e:
      quit(fmt"Failed to create directory: {result}, error: {e.msg}", -1)

proc meta(script: string, compiler_args: string, arguments: varargs[string]): ScriptMetaInfo =
  result.name = script
  result.compiled_path = script_path(script) / script
  result.script_path = getCurrentDir() / script
  result.arguments = @arguments
  result.compilation_arguments = compiler_args

proc serializeScriptInfo(filePath: string, scriptInfo: ScriptInfo): void =
  ##[
  Serializes ScriptInfo object to a file.

  Parameters:
    - filePath: The path to the file where the serialized data will be stored.
    - scriptInfo: The ScriptInfo object to be serialized.
  ]##
  let jsonText = %* scriptInfo
  let file = open(filePath, fmWrite)
  defer: close(file)
  try:
    write(file, jsonText)
  except IOError as e:
    quit(fmt"Failed to serialize script info to: {filePath}, error: {e.msg}", -1)

proc deserializeScriptInfo(filePath: string): ScriptInfo =
  ##[
    Deserializes ScriptInfo object from a file.

    Parameters:
      - filePath: The path to the file containing the serialized data.

    Returns:
      The deserialized ScriptInfo object.
  ]##
  let infoFile = open(filePath)
  defer: close(infoFile)
  try:
    let jsonText = readAll(infoFile)
    result = parseJson(jsonText).to ScriptInfo
  except IOError as e:
    quit(fmt"Failed to deserialize script info from: {filePath}, error: {e.msg}", -1)

proc require_compilation(meta_info: ScriptMetaInfo): bool =
  let infoPath = meta_info.compiled_path & ".info.json"

  let newHash = meta_info.script_path.hash().toHex

  var script_info: ScriptInfo
  if file_exists(infoPath):
    try:
      script_info = deserializeScriptInfo(infoPath)
    except IOError as e:
      quit(fmt"Failed to deserialize script info from: {infoPath}, error: {e.msg}", -1)
  else:
    script_info = ScriptInfo(
      hash: newHash,
      compilation_arguments: meta_info.compilation_arguments
    )

  let scriptLastMod = meta_info.script_path.getLastModificationTime
  let older = (not meta_info.compiled_path.fileExists) or (meta_info.compiled_path.getLastModificationTime < scriptLastMod)

  result = older or (script_info.hash != newHash) or (script_info.compilation_arguments != meta_info.compilation_arguments)

  if result:
    script_info.hash = newHash
    script_info.compilation_arguments = meta_info.compilation_arguments
    try:
      serializeScriptInfo(infoPath, script_info)
    except IOError as e:
      quit(fmt"Failed to serialize script info to: {infoPath}, error: {e.msg}", -1)

proc nbang*(
  compiler_args: string = "-d:release --hints:off --warnings:off",
  script: seq[string]
): int =
  if script.len == 0:
    quit("No script provided", -1)

  # Generate MetaInfo
  let meta_info = meta(script[0], compiler_args.replace "\"", script[1..^1])

  if meta_info.require_compilation:
    # Compile script
    let compiler_command = fmt"nim c {meta_info.compilation_arguments} --out:{meta_info.compiled_path} {meta_info.script_path}"
    let res = execShellCmd(compiler_command)
    if res != 0:
      quit(fmt"Failed to compile script with command {compiler_command}", -1)

  # Executes script
  result = startProcess(meta_info.compiled_path, args = meta_info.arguments, options={poParentStreams, poUsePath}).waitForExit

when isMainModule:
  import cligen
  dispatch nbang