module.exports = (robot) ->
  robot.hear /roll (\d*) (.*) diff(\d)/i, (res) ->
    numDie = res.match[1]
    character = res.match[2]
    name_array = character.split('-')
    name_array = name_array.map((str) ->
      str.charAt(0).toUpperCase() + str.slice(1);
    )
    prettyCharacter = name_array.join ' '

    sides = 10

    results = []
    i = 0
    while i < numDie
      results.push(Math.floor((Math.random() * sides) + 1))
      i++
    diff = res.match[3]
    successes = 0
    botches = 0
    i = 0
    while i < results.length
      if results[i] == 1
        botches++
      else if results[i] >= diff
        successes++
      i++
    totalSux = successes - botches
    if totalSux == 0
      successText = "[failed :(]"
    else if totalSux < 0
      successText = "[botched x#{botches}!]"
    else
      successText = "[#{totalSux} sux]"
    res.reply "#{prettyCharacter} rolled #{numDie}d10 for #{results.join(',')} #{successText}."