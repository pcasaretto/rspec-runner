spawn = require('child_process').spawn
fs = require('fs')
url = require('url')

class RspecRunner

  activate: ->
    atom.workspaceView.command 'rspec-runner:run', => @run()
    atom.workspaceView.command 'rspec-runner:stop', => @stop()

  run: ->
    editor = atom.workspace.getActiveEditor()
    return unless editor?

    path = editor.getPath()
    project = atom.project
    path = project.relativize(path)

    @execute(path)

  stop: ->
    if @child
      @child.kill()

  execute: (path) ->
    cmd = 'bundle exec rspec'
    @stop()

    args = if path then [path] else []
    splitCmd = cmd.split(/\s+/)
    if splitCmd.length > 1
      cmd = splitCmd[0]
      args = splitCmd.slice(1).concat(args)
    console.log cmd
    console.log args
    @child = spawn(cmd, args, cwd: atom.project.path)
    @child.stderr.on 'data', (data) =>
      console.log(data.toString())
    @child.stdout.on 'data', (data) =>
      console.log(data.toString())
    @child.on 'close', (code, signal) =>
      console.log('tests ended')
      @child = null

    startTime = new Date
    console.log("Running: #{cmd} #{path}")

module.exports = new RspecRunner
