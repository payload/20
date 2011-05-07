express = require 'express'
fs = require 'fs'

class HighscoreServer
    constructor: () ->
        @port = 10101
        @filename = 'highscore'
        @timeout = null
        @highscore = []
        @save_delay = 1000 # ms
        @svr = null
        process.on 'exit', @save

    load: (cb) =>
        fs.stat @filename, (err, stat) =>
            if stat
                json = fs.readFileSync @filename
                @highscore = JSON.parse json
            else
                @delayed_save()
                @highscore = []
            cb?()

    delayed_save: () =>
        if @timeout == null
            @timeout = setTimeout @save, @save_delay

    save: () =>
        if @timeout != null
            json = JSON.stringify @highscore
            fs.writeFile @filename, json, =>
                @timeout = null

    top10: () =>
        @highscore

    configure: (svr, cb) =>
        svr.use express.methodOverride()
        svr.use express.bodyParser()
        cb?()

    listen: (cb) =>
        svr = @svr = express.createServer()
        svr.configure => @configure svr

        svr.get '/top10', (req, res) =>
            res.send @top10()
        svr.post '/entry', (req, res, next) =>
            ret = @entry(req.body)
            if ret != null then res.send ret else next()

        svr.listen @port
        cb?()

    entry: (entry) =>
        { name, score } = entry
        return null unless name? and score?
        return null if name['push']? != score['push']?
        if name['push']?
            return null if name.length != score.length
            # list of names and list of scores with same length
            for i in [0...name.length]
                @highscore.push
                    name: name[i]
                    score: score[i]
        else # one name and one score
            @highscore.push entry
        @delayed_save()
        "#{@highscore.length}"

process.title = __filename[__dirname.length+1...]
say_something = -> console.log "#{process.title} running on port #{hs_srv.port}"
hs_srv = new HighscoreServer()
hs_srv.load hs_srv.listen say_something

