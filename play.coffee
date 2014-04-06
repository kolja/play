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
bookmark = null
bookmarkFilename = ".bookmark"

fs.readFile "#{opts.dir}/#{bookmarkFilename}", 'utf8', (err, data) ->

    bookmark = if (err) then null else JSON.parse(data).bookmark
    walker = walk.walk opts.dir

    walker.on "file", (root, fileStats, next) ->
        fileName = "#{root}/#{fileStats.name}"
        if (bookmark)
            if (bookmark is fileName)
                bookmark = null
                playlist.push fileName
        else
            playlist.push fileName
        next()

    walker.on "end", ->
        player = new Player playlist
        player.play()
        player.on 'playing', (item) ->
            fs.writeFile "#{opts.dir}/#{bookmarkFilename}", "{\"bookmark\":\"#{item.src}\"}", (err) ->
                if (err) then console.log err
            console.log "playing", item.src
        player.on 'played', (item) ->
            player.next()

        player.on 'error', (err) ->
            console.log err

