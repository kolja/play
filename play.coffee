#!/usr/bin/env coffee

opts = require 'commander'
walk = require 'walk'
Player = require 'player'
fs = require 'fs'

opts
  .version('0.0.0')
  .option('-d, --dir [directory]', 'specify a directory', '.')
  .parse(process.argv)

console.log 'playing...'
walker = walk.walk opts.dir
walker.on "file", (root, fileStats, next) ->
    if (fileStats.name.match /mp3$/)
        console.log "playing #{fileStats.name}"
        player = new Player "#{root}/#{fileStats.name}"
        player.play (err, player) ->
            next()
    else
        next()
console.log opts.dir
