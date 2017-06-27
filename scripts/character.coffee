require 'request'
util = require('util')

lookup_character = (res, user, name) ->
  res.http("http://combatmonkeyrpg.com/api/v1/users/#{user}/characters/#{name}")
    .get() (err, res, body) ->
      try
        json = JSON.parse(body)
        console.log util.inspect(json)
      catch error
        res.send "Character not found. Maybe you need to make one"

add_character = (res) ->


module.exports = (robot) ->
  robot.hear /set (character|char) (.*)/i, (res) ->
    console.log "Triggered by received message: #{res.
message} by #{res.message.user.id} in #{res.message.room}"
    name = res.match[2]
    user = res.message.user.id

    character = lookup_character(res, user, name)
    channel = res.message.room

    # characters = res.robot.brain.get('characters') || {}
  # characters[channel] = channel || ""
  # characters[channel][user] = user || ""
  # characters[channel][user][character]= { "name": character.name, "avatar_url": character.avatar_url } || {}
  # res.robot.brain.set('characters', characters)
  # res.robot.brain.save()


    res.send "User #{res.message.user.name} set character in #{res.message.room} to #{character.name}"


  robot.hear /show (characters|chars)/i, (msg) ->
    console.log "Triggered by received message: #{res.message} by #{res.message.user.id} in #{res.message.room}"
    user = res.message.user.id

    res.http("http://combatmonkeyrpg.com/api/v1/users/#{user}/characters/")
      .get() (err, res, body) ->
        try
          json = JSON.parse(body)
          res.send "#{util.inspect(json)}"
