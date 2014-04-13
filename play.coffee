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
        stream = fs.createReadStream(file, {'bufferSize': 4096})
        p = stream.pipe new lame.Decoder()
        p.on 'format', (format) =>
            p.pipe new Speaker(format)
            console.log "playing", file
            fs.writeFile "#{@directory}/#{@bookmarkFilename}", "{\"bookmark\":\"#{file}\"}", (err) ->
                if (err) then console.log err
        p.on 'end', =>
            @intermission @play, 1000

directory = process.argv[2]
if not directory
    throw "please name a directory with some audio-files to play"
else
    try isDir = fs.lstatSync(directory)?.isDirectory()
    if not isDir
        console.log "#{directory} doesn't appear to be a directory"
    else
        playlist = new Playlist directory


process.on 'SIGINT', ->
    console.log "\nexiting..."
    process.exit()
