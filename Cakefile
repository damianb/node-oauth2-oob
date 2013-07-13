fs = require 'fs'
path = require 'path'
{spawn, exec} = require 'child_process'
util = require 'util'

# ANSI Terminal Colors
bold = '\x1b[0;1m'
green = '\x1b[0;32m'
reset = '\x1b[0m'
red = '\x1b[0;31m'

# options for our various tools
jadeOpts = '-P'
coffeeOpts = '-b'
uglifyOpts = '-mc'
lessOpts = '--no-ie-compat -x'

# files to build/watch, etc.
files =
	coffee: [
		'oauth2'
		'application'
		'server'
		'utils'
		'storage/nedb'
	]

task 'build', 'build all - less, jade, coffeescript', ->
	invoke 'build:coffee'


task 'watch', 'watch and rebuild files when changed', ->
	invoke 'watch:coffee'

# individual build tasks
task 'build:coffee', 'build coffeescript files into js', -> build 'coffee'

# individual watch tasks
task 'watch:coffee', 'watch coffee files for changes and rebuild', -> watch 'coffee'

build = (type) ->
	fileset = switch
		when type is 'uglify' then 'coffee'
		when type is 'uglycoffee' then 'coffee'
		else type
	for file in files[fileset]
		compile type,file

watch = (type) ->
	invoke 'build:'+type
	fileset = switch
		when type is 'uglify' then 'coffee'
		when type is 'uglycoffee' then 'coffee'
		else type
	for file in files[fileset] then do ->
		_file = file
		path = switch
			when type is 'coffee' then "src/#{_file}.coffee"
		fs.watchFile path, (curr, prev) ->
			if +curr.mtime isnt +prev.mtime
				compile type,_file

compile = (type, file) ->
	#file = file.replace '/','\\' if process.platform is 'win32'
	source = path.join './src/', "#{file}.coffee"
	dest = path.join './lib/', "#{file}.js"
	cmdLine = switch
		when type is 'coffee' then "coffee #{coffeeOpts} -cs < #{source} > #{dest}"
		else throw new Error 'unknown compile type'
	exec cmdLine, (err, stdout, stderr) ->
		if err
			log "#{type}: failed to compile #{source}; #{err}", stderr, true
		else
			log "#{type}: compiled #{file} successfully"

log = (message, explanation, isError = false) ->
	util.log (if isError then "#{red} err: #{message}#{reset}" else "#{green}#{message.trim()}#{reset}") + ' ' + (explanation or '')
