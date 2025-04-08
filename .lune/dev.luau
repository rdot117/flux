-- modules
local fs = require("@lune/fs")
local process = require "@lune/process"
local task = require "@lune/task"

-- build directory
local exists = pcall(fs.readDir, "build")
if not exists then
    fs.writeDir("build")
end

-- sourcemap updates
process.spawn("rojo", { "sourcemap", "default.project.json", "--output", "sourcemap.json" })
task.spawn(process.spawn, "rojo", { "sourcemap", "default.project.json", "--output", "sourcemap.json", "--watch" })
print "[dev]: listening for rojo sourcemap updates"

-- rojo serve
task.spawn(process.spawn, "rojo", {"serve", "default.project.json" })
print "[dev]: rojo serve running"
