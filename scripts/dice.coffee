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
#   roll x dy description text diffz - Dicey rolls x number of dy dice at difficulty z, if dy is left off, it defaults to a d10. If difficulty is left off, it defaults to diff6. If diff0, no succeses are calculated.
#   !flip - Dicey flips a Coin
#   !odds - Dicey does an odds/evens, returns success when number is odd
#   !evens - Dicey does an odds/evens, returns success when number is even
#   !percent - Dicey returns a random percent
# Notes:
#
# Author:
#   Angela Mancini

DEFAULT_DIFF = 6

DICE_SIDES = 10

STATUS_COLORS = {
  success: "#3ccc76",
  failed: "#de8822",
  botched: "#d00909",
  init: "#6be7fc",
  heads: "#6b83fc",
  tails: "#ffc700",
  generic: "#f073d4",
  debug: "#7038cc",
  percent: "#ffc453"
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

calc_success = (results, difficulty) ->
  ones = results.filter (x) -> x == 1
  botches = ones.length
  above_diff = results.filter (x) -> x >= difficulty
  successes = above_diff.length
  total_sux = successes - botches
  return { total: total_sux, botches: botches }


format_message = (text,color) ->
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
  robot.hear /^roll(?:\s)?([1-9]+)(?:\s)?(d\d{1,3})?(?:\s)?(.+?(?=diff|$))(diff(?:\s)?(\d{1,2}))?/i, (res) ->
    console.log "Triggered by received message: #{res.message}"
    user = res.message.user.name
    num_die = +res.match[1]
    if res.match[2] == undefined
      dice_sides = DICE_SIDES
    else
      dice_sides = +(res.match[2].substring(1))
    description = res.match[3]
    if res.match[5] == undefined
      difficulty = DEFAULT_DIFF
    else
      difficulty = +res.match[5]

    roll = roll_multiple(num_die, dice_sides)
    console.log "==========\nNum Dice: #{num_die}\nDice Type: #{dice_sides}\nDescription: #{description}\nDifficulty: #{difficulty}\n=========="
    if difficulty == 0
      color = STATUS_COLORS['generic']
      text = "@#{user} _#{description}_ rolled #{num_die} d#{dice_sides} for [#{roll}]."
    else
      calc = calc_success(roll, difficulty)
      if calc['total'] == 0
        color = STATUS_COLORS['failed']
        result_text = "*Failed* "
      else if calc['total']  < 0
        color = STATUS_COLORS['botched']
        result_text = "*Botched x#{calc['botches']}* "
      else
        color = STATUS_COLORS['success']
        result_text = "*#{calc['total']} Successes* "
      text = "@#{user} _#{description}_ rolled #{num_die} d#{dice_sides} at diff #{difficulty} for #{result_text}[#{roll}]."

    attachment = format_message(text,color)
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
    attachment = format_message(text,STATUS_COLORS['init'])
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
    attachment = format_message(text,color)
    res.send(username: res.robot.name, attachments: attachment)

  robot.hear /!odds/i, (res) ->
    console.log "Triggered by received message: #{res.message}"
    user = res.message.user.name
    roll = roll_one(DICE_SIDES)
    if roll % 2 == 0
      text = "called odds. Result: Even! [#{roll}]"
      color = STATUS_COLORS['botched']
    else
      text = "called odds. Result: Odd! [#{roll}]"
      color = STATUS_COLORS['success']
    text = "@#{user} #{text}"
    attachment = format_message(text,color)
    res.send(username: res.robot.name, attachments: attachment)

  robot.hear /!evens/i, (res) ->
    console.log "Triggered by received message: #{res.message}"
    user = res.message.user.name
    roll = roll_one(DICE_SIDES)
    if roll % 2 == 0
      text = "called evens. Result: Even! [#{roll}]"
      color = STATUS_COLORS['success']
    else
      text = "called evens. Result: Odd! [#{roll}]"
      color = STATUS_COLORS['botched']
    text = "@#{user} #{text}!"
    attachment = format_message(text,color)
    res.send(username: res.robot.name, attachments: attachment)

  robot.hear /!percent/i, (res) ->
    console.log "Triggered by received message: #{res.message}"
    user = res.message.user.name
    roll = roll_multiple(1, 100)
    text = "@#{user} #{roll}%"
    attachment = format_message(text,STATUS_COLORS['percent'])
    res.send(username: res.robot.name, attachments: attachment)
