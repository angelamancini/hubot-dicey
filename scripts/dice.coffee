# Description:
#   Rolls dice according to wod classic rules
#
# Commands:
#   roll x description text diffy - Dicey rolls x number of dice at difficulty y
#   roll x description text diff y - Dicey rolls x number of dice at difficulty y
#   roll x description text - Dicey rolls x number of dice at default difficulty
# Notes:
#
# Author:
#   Angela Mancini
# {
#     "attachments": [
#         {
#           "color": "#e47a4c",
# 			"fields": [
#                 {
#                     "title": "Results",
#                     "value": "Trevor rolled 7 dice for WP: [1,2,3,4,5,6,7], *failed*",
#                     "short": false
#                 }
#             ]
#         }
#     ]
# }

DEFAULT_DIFF = 6

DICE_SIDES = 10

STATUS_COLORS = {
  success: "#3ccc76",
  failed: "#df8e2e",
  botched: "#d00909",
  init: "#6be7fc"
}

roll_one = (sides) ->
  Math.floor((Math.random() * sides) + 1)

roll_init = (character, base) ->
  roll = roll_one(DICE_SIDES)
  init = roll + base
  return { init: init, base: base, character: character }

roll_multiple = (res, numDie, difficulty, action_text) ->
  results = []
  i = 0
  while i < numDie
    results.push(roll_one(DICE_SIDES))
    i++
  ones = results.filter (x) -> x == 1
  one_count = ones.length
  successes = results.filter (x) -> x >= difficulty
  success_count = successes.length
  totalSux = success_count - one_count
  return { action_text: action_text, num_die: numDie, diff: difficulty, results: results, successes: success_count, botches: one_count, total_sux: totalSux }

format_message = (user,roll,init,action_text='') ->
  if init
    text = "@#{user} #{roll["character"]} init: #{roll["init"]} (base #{roll["base"]})"
    att = [
      {
        fallback: text,
        color: "#{STATUS_COLORS['init']}",
        text: text
      }
    ]
    return JSON.stringify(att)
  else
    if roll["total_sux"] == 0
      color = STATUS_COLORS['failed']
      result_text = "*Failed*"
    else if roll["total_sux"] < 0
      color = STATUS_COLORS['botched']
      result_text = "*Botched x#{roll["botches"]}*"
    else
      color = STATUS_COLORS['success']
      result_text = "*#{roll["total_sux"]} Successes*"

    text = "@#{user} #{action_text} rolled #{roll["num_die"]} dice at diff #{roll["diff"]} for #{result_text} [#{roll["results"]}] ."
    att = [
      {
        fallback: text,
        color: color,
        text: text,
        mrkdwn_in: ["text"]
      }
    ]
    return JSON.stringify(att)

module.exports = (robot) ->
  robot.hear /roll (\d*)\s(.*) (?:diff(\d{1,2}|\s\d{1,2}))?$/i, (res) ->
    console.log "Triggered by received message: #{res.message}"
    numDie = res.match[1]
    action_text = res.match[2]
    user = res.message.user.name
    difficulty = res.match[3]
    console.log difficulty
    if difficulty == undefined
      console.log "Falling back to default diff: #{DEFAULT_DIFF}"
      difficulty = DEFAULT_DIFF

    roll = roll_multiple(res, numDie, difficulty)
    attachment = format_message(user,roll, false, action_text)
    res.send(username: res.robot.name, attachments: attachment)

  robot.hear /roll init (.*) (\d*)/i, (res) ->
    character = res.match[1]
    name_array = character.split('-')
    name_array = name_array.map((str) ->
      str.charAt(0).toUpperCase() + str.slice(1);
    )
    user = res.message.user.name
    prettyCharacter = name_array.join ' '
    base = parseInt(res.match[2], 10 )
    roll = roll_init(prettyCharacter, base)
    attachment = format_message(user,roll,true)
    res.send(username: res.robot.name, attachments: attachment)
