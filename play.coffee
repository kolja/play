#!/usr/bin/env coffee

opts = require 'commander'
walk = require 'walk'
Player = require 'player'
fs = require 'fs'

opts
  .version('0.0.0')
  .option('-d, --dir [directory]', 'specify a directory', '.')
  .parse(process.argv)

playlist = []
walker = walk.walk opts.dir
walker.on "file", (root, fileStats, next) ->
    playlist.push "#{root}/#{fileStats.name}"
    next()

walker.on "end", ->
    player = new Player playlist
    player.play()
    player.on 'playing', (item) ->
        console.log "playing", item.src
    player.on 'played', (item) ->
        console.log this
        player.next()

    player.on 'error', (err) ->
        console.log err

