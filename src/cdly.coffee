aws = require "aws-sdk"
osenv = require "osenv"
util = require "util"
jpath = require "jmespath"
_ = require "underscore"
cmd = require "commander"

commands =
  info:
    help: "Display information about the aws api and configuration"
    cmd: ->
      console.log "region: #{aws.config.region}"
      console.log "api version: #{aws.VERSION}"


aws.config = new aws.Config()

# XXX: Need to load the region from a config file.
#
aws.config.update({region: "ap-southeast-2"})

ec2 = new aws.EC2()

nameFilter = (name) ->
  Filters: [
      { Name: "tag:Name", Values: ["#{name}"]}
    ]

started = (data) ->
  data.Reservations[0].Instances[0].State.Name == "Started"

instanceId = (data) ->
  data.Reservations[0].Instances[0].InstanceId

cmd
  .version("0.0.1")

cmd
  .command("show <name>")
  .action (name) ->
    ec2.describeInstances nameFilter(name), (err, data) ->
      if (err)
        console.log err.stack
      else
        console.log util.inspect(data, {showHidden: false, depth: null})

cmd
  .command("list")
  .action () ->
    ec2.describeInstances {}, (err, data) ->
      if (err)
        console.log err.stack
      else
        console.log (_.flatten(jpath.search(data, "Reservations[*].Instances[*].Tags[?Key==`Name`].Value")))

cmd
  .command("key <name>")
  .action (name) ->
    ec2.describeInstances nameFilter(name), (err, data) ->
      if (err)
        console.log err.stack
      else
        console.log data.Reservations[0].Instances[0].KeyName

cmd
  .command("status <name>")
  .action (name) ->
    ec2.describeInstances nameFilter(name), (err, data) ->
      if (err)
        console.log err.stack
      else
        console.log data.Reservations[0].Instances[0].State.Name

cmd
  .command("start <name>")
  .action (name) ->
    ec2.describeInstances nameFilter(name), (err, data) ->
      if (err)
        console.log err.stack
      else
        if (not started(data))







cmd.parse process.argv
