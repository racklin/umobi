requirejs = require("requirejs")
path = require("path")
fs = require("fs")
util = require("util")
execSync = require "exec-sync"

module.exports = (grunt) ->
  config = grunt.config.get("global")
  helpers = config.helpers
  grunt.registerTask "css:compile", "use require js to sort out deps", ->
    cssConfig = grunt.config.get('css')
    theme = cssConfig.theme
    themeFile = cssConfig.themeFile
    require = cssConfig.require
    
    # pull the includes together using require js
    requirejs.optimize require.all
    
    # pull the includes together using require js
    requirejs.optimize require.structure
    
    # simple theme file compile
    # grunt.file.write themeFile + ".css", "css/themes/" + theme + "/umobi.css"

  grunt.registerTask "css:fontawesome","copy fontawesome files", ->
    grunt.log.ok("Copying font-awesome files...")
    wrench = require "wrench"
    wrench.copyDirSyncRecursive("css/customfont", "compiled/customfont")
  
  # TODO image copy would be better in compile though not perfect
  grunt.registerTask "css:images", "copy images for css", ->
    done = @async()
    theme = grunt.config.get("css").theme
    require = grunt.config.get("css").require
    global_config = grunt.config.get("global")
    
    # copy images directory
    imagesPath = path.join(global_config.dirs.output, "images")
    fileCount = 0
    grunt.file.mkdir imagesPath
    grunt.file.recurse "css/themes/" + theme + "/images", (full, root, sub, filename) ->
      fileCount++
      is_ = fs.createReadStream(full)
      os = fs.createWriteStream(path.join(imagesPath, filename))
      util.pump is_, os, ->
        fileCount--
        done()  if fileCount is 0



  grunt.registerTask "css:cleanup", "compile and minify the css", ->
    theme = grunt.config.get("css").theme
    require = grunt.config.get("css").require
    global_config = grunt.config.get("global")
    
    # remove the requirejs compile output
    fs.unlink require.all.out
    fs.unlink require.structure.out

  
  # NOTE the progression of events is not obvious from the above
  #      compile -> concat x 3 -> min all -> cleanup the compiled stuff
  grunt.registerTask "css", "config:async css:fontawesome sass:compile css:compile concat:regular concat:structure concat:theme cssmin css:cleanup css:images".split(" ")
