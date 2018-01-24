# Description:
#   Sends queries to SumoLogic and returns results.
#
# Dependencies:
#   "request": "2.82.0"
#
# Configuration:
#   SUMOBOT_API_ENDPOINT - endpoint of sumobot api gateway
#
# Commands:
#   show sumo categories for na preprod extra - returns SourceCategories for
#     a particular landscape, environment and product
#   show sumo categories|category for <landscape> <environment> <product>
#
# Notes:
#   Must have sumobot lambda/api gateway set up.
#
# Author:
#   angelamancini

require 'request'

query_sumologic = (res, query, s_from = null, s_to = null, tz = 'UTC') ->
  data = {
    "query": query,
    "timezone": tz
  }
  if s_to
    data["search_to"] = s_to

  if s_from
    data["search_from"] = s_from
  res.http("#{process.env.SUMOBOT_API_ENDPOINT}/search/create")
  .headers('Content-Type': 'application/json', 'Content-Length': data.length)
  .post(JSON.stringify(data)) (err, response, body) ->
    search = JSON.parse(body)
    query_status(res, search["id"])

query_status = (res, job_id) ->
  console.log 'gets status of job'
  console.log job_id
  res.http("#{process.env.SUMOBOT_API_ENDPOINT}/search/#{job_id}}/status")
  .headers('Content-Type': 'application/json')
  .get() (err, response, body) ->
    console.log "Response: #{response.toString() }"
    console.log "Body: #{JSON.stringify(body)}"


query_records = (job_id, limit) ->
  console.log ''


module.exports = (robot) ->
  # show sumo categories for landscape environment product
  robot.hear /show sumo.* (.*categories|.*category) for (.*) (.*) (.*)/i,
  (res) ->
    console.log "Triggered by received message: #{res.match}"
    user = res.message.user.name
    landscape = res.match[2]
    environment = res.match[3]
    product = res.match[4]
    res.reply("Looking for SumoLogic log categories for \
#{landscape}, #{environment}, #{product} :spinner:")

    query = "_sourceCategory=lsm/* | parse field=_sourceCategory \
\"lsm/*/*/*/*/*\" as environment, landscape, family, product, log \
| where family in (\"tracks\",\"accountants-groups-group\",\
\"accountants-group\",\"sageone\",\"sageview\")\
|count by _sourceCategory, environment, landscape, product, family \
| fields -_count| sort +_sourceCategory | where landscape matches #{landscape} \
and environment matches #{environment} and product matches #{product}"
    query_sumologic(robot, query)
