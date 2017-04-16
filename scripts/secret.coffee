module.exports = (robot) ->
  robot.respond /tell me a secret$/i, (msg) ->
    msg.send {room: msg.envelope.user.name}, 'Whisper whisper whisper'
