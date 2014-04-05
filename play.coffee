#!/usr/bin/env coffee

opts = require 'commander'
walk = require 'walk'
fs = require 'fs'

opts
  .version('0.0.0')
  .option('-d, --dir [directory]', 'specify a directory', '.')
  .parse(process.argv)

console.log 'playing...'
walker = walk.walk opts.dir
walker.on "file", (root, fileStats, next) ->
    console.log "playing #{fileStats.name}"
    exec "afplay #{root}/#{fileStats.name}", next()
console.log opts.dir
