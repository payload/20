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

        svr.get '/top10/:score(\\d+)', (req, res, next) =>
            ret = @entry_get(req.params)
            if ret != null then res.send ret else next()
        svr.post '/entry', (req, res, next) =>
            ret = @entry_post(req.body)
            if ret != null then res.send ret else next()

        svr.listen @port
        cb?()

    entry_get: (wish) =>
        { score: myscore } = wish
        myscore = parseInt myscore
        return null if myscore is undefined or myscore is NaN
        i = 0
        for entry in @highscore
            { name, score } = entry
            break if score < myscore
            i += 1
        # before
        before = @highscore[...i]
        score = before[0..6]
        score.push(before[-1..][0]) if i-1 > 6
        rank = 1
        for x in score
            x.rank = rank
            rank += 1
        # own
        score.push
            rank: rank
            name: undefined
            score: myscore
        # after
        l = score.length
        after = @highscore[i..i+9-l]
        for x in after
            rank += 1
            x.rank = rank
        score.concat(after)

    entry_post: (entry) =>
        { name, score } = entry
        score = parseInt score
        return null unless name? and score != undefined and score != NaN
        return null if name['push']? != score['push']?
        [name, score] = [[name],[score]] if not name['push']?
        return null if name.length != score.length
        for i in [0...name.length]
            j = 0
            for other in @highscore
                { name: oname, score: oscore } = other
                console.log oscore, score[i], oscore < score[i]
                break if oscore < score[i]
                j += 1
            @highscore.splice j, 0,
                name: name[i]
                score: score[i]
        @delayed_save()
        "#{@highscore.length}"

process.title = __filename[__dirname.length+1...]
say_something = -> console.log "#{process.title} running on port #{hs_srv.port}"
hs_srv = new HighscoreServer()
hs_srv.load hs_srv.listen say_something

