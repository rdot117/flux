local fs = require "@lune/fs"
local process = require "@lune/process"
local task = require "@lune/task"

fs.writeDir("build")
print "[dev]: wrote to  `build` directory"

-- sourcemap updates
process.spawn("rojo", { "sourcemap", "default.project.json", "--output", "sourcemap.json" })
task.spawn(process.spawn, "rojo", { "sourcemap", "default.project.json", "--output", "sourcemap.json", "--watch" })
print "[dev]: listening for rojo sourcemap updates"

-- darklua processes
task.spawn(process.spawn, "darklua", { "process", "src", "build/src", "--watch" })
task.spawn(process.spawn, "darklua", { "process", "packages", "build/packages", "--watch" })
print "[dev]: listening for darklua process updates"

-- rojo serve
task.spawn(process.spawn, "rojo", {"serve", "build.project.json" })
print "[dev]: rojo serve running"
