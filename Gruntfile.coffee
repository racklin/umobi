path = require("path")
fs = require("fs")
execSync = require("exec-sync")
module.exports = (grunt) ->
  
  # this will change for the deploy target to include version information
  outputPath = (name) -> path.join(dirs.output, name)

  dirs = undefined
  names = undefined
  min = {}
  cssmin = {}
  theme = undefined
  rootFile = undefined
  structureFile = undefined
  themeFile = undefined
  verOfficial = undefined
  suffix = undefined
  dirs =
    output: "compiled"
    temp: "tmp"

  verOfficial = grunt.file.read("version.txt").replace(/\n/, "")
  suffix = (if process.env.IS_DEPLOY_TARGET is "true" then "-" + verOfficial else "")
  names =
    base: "umobi" + suffix
    root: "umobi" + suffix
    structure: "umobi.structure" + suffix
    theme: "umobi.theme" + suffix

  rootFile = outputPath(names.root)
  structureFile = outputPath(names.structure)
  themeFile = outputPath(names.theme)
  
  # TODO again, I'd like to use grunt params but I'm not sure
  #      how to get that working with a custom task with deps
  theme = process.env.THEME or "default"
  
  # Project configuration.
  grunt.config.init
    jshint:
      options:
        curly: true
        eqeqeq: true
        
        # (function(){})() seems acceptable
        immed: false
        latedef: true
        newcap: true
        noarg: true
        sub: true
        undef: true
        boss: true
        eqnull: true
        browser: true

      globals:
        jQuery: true
        $: true
        
        # qunit globals
        # TODO would be nice to confine these to test files
        module: true
        ok: true
        test: true
        asyncTest: true
        same: true
        start: true
        stop: true
        expect: true
        
        # require js global
        define: true
        require: true

    
    # TODO add test files here once we can specify different configs for
    #      different globs
    lint:
      files: ["js/**/*.mobile.*.js", "js/*/*.js"]

    
    # NOTE these configuration settings are used _after_ compilation has taken place
    #      using requirejs. Thus the .compiled extensions. The exception being the theme concat
    concat:
      js:
        src: ["<banner:global.ver.header>", rootFile + ".compiled.js"]
        dest: rootFile + ".js"

      structure:
        src: ["<banner:global.ver.header>", structureFile + ".compiled.css"]
        dest: structureFile + ".css"

      regular:
        src: ["<banner:global.ver.header>", rootFile + ".compiled.css"]
        dest: rootFile + ".css"

      theme:
        src: ["<banner:global.ver.header>", "css/themes/" + theme + "/umobi.theme.css"]
        dest: themeFile + ".css"

    
    # NOTE the keys are filenames which, being stored as variables requires that we use
    #      key based assignment. See below.
    min: `undefined`
    cssmin: `undefined`
    
    # JS config, mostly the requirejs configuration
    js:
      require:
        baseUrl: "js"
        name: "umobi"
        exclude: [
          "jquery"
          "coffee-script"
          "depend"
          "text"
          "text!../version.txt"
        ]
        out: rootFile + ".compiled.js"
        
        # wrap: { startFile: 'build/wrap.start', endFile: 'build/wrap.end' },
        findNestedDependencies: true
        skipModuleInsertion: true
        optimize: "none"
    
    # CSS config, mostly the requirejs configuration
    css:
      theme: process.env.THEME or "default"
      themeFile: themeFile
      require:
        all:
          cssIn: "css/themes/default/umobi.css"
          optimizeCss: "standard.keepComments.keepLines"
          baseUrl: "."
          out: rootFile + ".compiled.css"

        structure:
          cssIn: "css/structure/umobi.structure.css"
          out: structureFile + ".compiled.css"

    global:
      dirs: dirs
      names: names
      files:
        license: "LICENSE.txt"

      
      # other version information is added via the asyncConfig helper that
      # depends on git commands (eg ver.min, ver.header)
      ver:
        official: verOfficial
        min: "/*! umobi v<%= build_sha %> umobi.com !*/"
        gitLongSha: "git log -1 --format=format:\"Git Build: SHA1: %H <> Date: %cd\""
        gitShortSha: "git log -1 --format=format:\"%H\""

      shas: {}

  
  # MIN configuration
  min[rootFile + ".min.js"] = ["<banner:global.ver.min>", rootFile + ".js"]
  grunt.config.set "min", min
  
  # CSSMIN configuration
  cssmin[rootFile + ".min.css"] = ["<banner:global.ver.min>", rootFile + ".css"]
  cssmin[structureFile + ".min.css"] = ["<banner:global.ver.min>", structureFile + ".css"]
  cssmin[themeFile + ".min.css"] = ["<banner:global.ver.min>", themeFile + ".css"]
  grunt.config.set "cssmin", cssmin
  
  # set the default task.
  grunt.registerTask "default", "lint"
  grunt.registerTask "sass", "compile sass files into css file", ->
    grunt.log.writeln "sass --update css"
    execSync "sass --update css"

  
  # csslint and cssmin tasks
  grunt.loadNpmTasks "grunt-css"
  
  # authors task
  grunt.loadNpmTasks "grunt-git-authors"
  grunt.loadNpmTasks "grunt-junit"
  grunt.loadNpmTasks "grunt-coffee"
  
  # Ease of use aliases for users who want the zip and docs
  grunt.registerTask "docs", "js css legacy_tasks:docs"
  grunt.registerTask "zip", "js css legacy_tasks:zip"

  
  # load the project's default tasks
  grunt.loadTasks "build/tasks"
