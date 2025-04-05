local process = require "@lune/process"
local task = require "@lune/task"
local install = require "install"

install()

-- sourcemap updates
process.spawn("rojo", { "sourcemap", "default.project.json", "--output", "sourcemap.json" })
task.spawn(process.spawn, "rojo", { "sourcemap", "default.project.json", "--output", "sourcemap.json", "--watch" })
print "[dev]: listening for rojo sourcemap updates"

-- rojo serve
task.spawn(process.spawn, "rojo", {"serve", "build.project.json" })
print "[dev]: rojo serve running"
