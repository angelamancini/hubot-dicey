# @Author: Angela Mancini <angelamancini>
# @Date:   2016-05-25T17:32:09-04:00
# @Email:  angeladmancini@gmail.com
# @Project: Combat Monkey
# @Filename: dice.coffee
# @Last modified by:   angelamancini
# @Last modified time: 2017-05-07T23:12:59-04:00
# @License: GPL-3.0

# Description:
#   Rolls dice according to wod classic rules
#
# Commands:
#   roll x description text diffy - Dicey rolls x number of dice at difficulty y
#   roll x description text diff y - Dicey rolls x number of dice at difficulty y
#   roll x description text - Dicey rolls x number of dice at default difficulty
#   !flip - Dicey flips a Coin
#   !odds - Dicey does an odds/evens, returns success when number is odd
#   !evens - Dicey does an odds/evens, returns success when number is even
#   !roll x dy - Dicey rolls x number of a y-sided dice
# Notes:
#
# Author:
#   Angela Mancini

DEFAULT_DIFF = 6

DICE_SIDES = 10

STATUS_COLORS = {
  success: "#3ccc76",
  failed: "#df8e2e",
  botched: "#d00909",
  init: "#6be7fc",
  heads: "#6b83fc",
  tails: "#ffc700",
  generic: "#f073d4"
}

roll_one = (sides) ->
  Math.floor((Math.random() * sides) + 1)

roll_multiple = (num_die, sides) ->
  results = []
  i = 0
  while i < num_die
    results.push(roll_one(sides))
    i++
  return results

roll_with_diff = (num_die, sides, difficulty) ->
  results = roll_multiple(num_die, sides)
  ones = results.filter (x) -> x == 1
  one_count = ones.length
  successes = results.filter (x) -> x >= difficulty
  success_count = successes.length
  totalSux = success_count - one_count
  return { results: results, successes: success_count, botches: one_count, total_sux: totalSux }

format_message = (roll,text,color) ->
  att = [
    {
      fallback: text,
      color: color,
      text: text,
      mrkdwn_in: ['text']
    }
  ]
  return JSON.stringify(att)

module.exports = (robot) ->
  # Normal d10 roll with difficulty
  robot.hear /NOT ^!roll.*$|^roll(\d{1,2}|\s\d{1,2})\s(.*)(?:\sdiff(\d{1,2}|\s\d{1,2}))?/i, (res) ->
    console.log "Triggered by received message: #{res.message}"
    num_die = res.match[1].replace /^\s+$/g, ""
    action_text = res.match[2]
    user = res.message.user.name
    difficulty = res.match[3]
    if difficulty == undefined
      console.log "Falling back to default diff: #{DEFAULT_DIFF}"
      difficulty = DEFAULT_DIFF

    console.log "Num Dice: [#{num_die}] #{typeof +num_die}. Action Text: #{action_text}. Difficulty: [#{difficulty}]"
    roll = roll_with_diff(+num_die, DICE_SIDES, +difficulty)
    if roll['total_sux'] == 0
      color = STATUS_COLORS['failed']
      result_text = "*Failed*"
    else if roll['total_sux'] < 0
      color = STATUS_COLORS['botched']
      result_text = "*Botched x#{roll['botches']}*"
    else
      color = STATUS_COLORS['success']
      result_text = "*#{roll['total_sux']} Successes*"

    text = "@#{user} #{action_text} rolled #{num_die} dice at diff #{difficulty} for #{result_text} [#{roll['results']}]."
    attachment = format_message(roll,text,color)
    res.send(username: res.robot.name, attachments: attachment)

  # Initiative Roll
  robot.hear /roll init (.*) (\d*)/i, (res) ->
    console.log "Triggered by received message: #{res.message}"
    character = res.match[1]
    name_array = character.split('-')
    name_array = name_array.map((str) ->
      str.charAt(0).toUpperCase() + str.slice(1);
    )
    user = res.message.user.name
    prettyCharacter = name_array.join ' '
    base = parseInt(res.match[2], 10)
    roll = roll_one(DICE_SIDES)
    init = roll + base
    text = "@#{user} #{prettyCharacter} init: #{init} (base #{base})"
    attachment = format_message(roll,text,STATUS_COLORS['init'])
    res.send(username: res.robot.name, attachments: attachment)

  # Coin Flip
  robot.hear /!flip/i, (res) ->
    console.log "Triggered by received message: #{res.message}"
    user = res.message.user.name
    roll = roll_one(DICE_SIDES)
    if roll % 2 == 0
      text = "Heads"
      color = STATUS_COLORS['heads']
    else
      text = "Tails"
      color = STATUS_COLORS['tails']
    text = "@#{user} #{text}!"
    attachment = format_message(roll,text,color)
    res.send(username: res.robot.name, attachments: attachment)

  robot.hear /!odds/i, (res) ->
    console.log "Triggered by received message: #{res.message}"
    user = res.message.user.name
    roll = roll_one(DICE_SIDES)
    if roll % 2 == 0
      text = "called evens. Result: Even! [#{roll}]"
      color = STATUS_COLORS['botched']
    else
      text = "called odds. Result: Odd! [#{roll}]"
      color = STATUS_COLORS['success']
    text = "@#{user} #{text}"
    attachment = format_message(roll,text,color)
    res.send(username: res.robot.name, attachments: attachment)

  robot.hear /!evens/i, (res) ->
    console.log "Triggered by received message: #{res.message}"
    user = res.message.user.name
    roll = roll_one(DICE_SIDES)
    if roll % 2 == 0
      text = "called evens. Result: Even! [#{roll}]"
      color = STATUS_COLORS['success']
    else
      text = "called odds. Result: Odd! [#{roll}]"
      color = STATUS_COLORS['botched']
    text = "@#{user} #{text}!"
    attachment = format_message(roll,text,color)
    res.send(username: res.robot.name, attachments: attachment)

  robot.hear /^!roll (\d*)(?:\s)(?:d)?(?:\s)?(\d*)/i, (res) ->
    console.log "Triggered by received message: #{res.message}"
    user = res.message.user.name
    num_dice = res.match[1]
    sides = res.match[2]
    roll = roll_multiple(num_dice, +sides)
    text = "@#{user} rolled #{num_dice} d#{sides}. Result: [#{roll}]"
    attachment = format_message(roll,text,STATUS_COLORS['generic'])
    res.send(username: res.robot.name, attachments: attachment)
