#!/usr/bin/env coffee

walk = require 'walk'
fs = require 'fs'
lame = require 'lame'
Speaker = require 'speaker'

class Playlist

    constructor: (@directory) ->

        @theList = []
        @index = null
        @bookmarkFilename = ".bookmark"

        fs.readFile "#{@directory}/#{@bookmarkFilename}", "utf8", (err, data) =>

            bookmark = if (err) then null else JSON.parse(data).bookmark
            walker = walk.walk @directory

            walker.on "file", (root, fileStats, next) ->
                fileName = "#{root}/#{fileStats.name}"
                if (bookmark)
                    if (bookmark is fileName)
                        bookmark = null
                        playlist.addFile fileName
                else
                    playlist.addFile fileName
                next()

            walker.on "end", => @play()

    addFile: (filename) =>
        @theList.push filename

    next: =>
        @index = switch @index
            when null then 0
            when @theList.length then null
            else @index + 1
        @theList[@index]

    intermission: (callback, duration) ->
        duration ?= 100
        setTimeout callback, duration

    punch: ->
        #currentTime = process.hrtime()[0]
        #if @timeDiff then currentTime - @timeDiff else currentTime

    reset: =>
        fs.unlink "#{@directory}/#{@bookmarkFilename}", (err) -> throw err if err

    play: =>
        if not file = @next()
            @reset()
            return
        p = this
        fs.createReadStream(file, {'bufferSize': 4096})
            .pipe new lame.Decoder()
            .on 'format', (format) ->
                @pipe new Speaker(format)
                console.log "playing", file
                fs.writeFile "#{p.directory}/#{p.bookmarkFilename}", "{\"bookmark\":\"#{file}\"}", (err) ->
                    if (err) then console.log err
            .on 'end', =>
                @intermission @play, 1000


playlist = new Playlist process.argv[2]


process.on 'SIGINT', ->
    console.log "\nexiting..."
    process.exit()
