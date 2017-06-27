require 'request'
Util = require "util"

module.exports = (robot) ->
  robot.hear /set (character|char) (.*)/i, (msg) ->
    console.log "Triggered by received message: #{msg.message} by #{msg.message.user.id} in #{msg.message.room}"
    character = msg.match[2]
    user = msg.message.user.id
    channel = msg.message.room

    msg.http("http://localhost:3000/api/v1/users/#{user}/characters/#{character}")
      .get() (err, res, body) ->
        try
          json = JSON.parse(body)
          msg.send "Name: #{json.name}\n
         avatar: #{json.avatar_url}"
        catch error
          msg.send "Character not found. Maybe you need to make one"
