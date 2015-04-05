// Gruntfile
module.exports = function(grunt) {
var autoprefixer = require('autoprefixer-core');
require('load-grunt-tasks')(grunt);

  // Project configuration.
  grunt.initConfig({

    pkg: grunt.file.readJSON('package.json'),

    watch: {
      css: {
        files: ['_sass/*.scss'],
        tasks: ['sass', 'postcss', 'shell:jekyllBuild'],
        options: {
          spawn: false,
          interrupt: true,
          atBegin: true
        }
      },

      jekyll: {
        files: ['index.html', '_includes/*.html', 'filters/*.*',  '_layouts/*.*', '_posts/*.*'],
        tasks: ['shell:jekyllBuild']
      }

    },

    sass: {
      dist: {
        options: {
          style: 'expanded',
          sourcemap: 'none'
        },
        files: {
          '_site/css/main.css':'_sass/main.scss'
        }
      }
    },

    shell: {
      jekyllServe: {
        command: 'jekyll serve --no-watch'
      },

      jekyllBuild: {
        command: 'jekyll build'
      }
    },


    postcss: {
      options: {
        map: true,
        processors: [
          autoprefixer({ browsers: ['last 2 version'] }).postcss
        ]
      },
      dist: {
        src: '_site/css/*.css'
      }
    },

    concurrent: {
      tasks: ['shell:jekyllServe', 'watch'],
      options: {
        logConcurrentOutput: true
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-postcss');
  grunt.loadNpmTasks('grunt-concurrent');

  // grunt.registerTask('default', ['shell:jekyllServe', 'watch']);
  grunt.registerTask('default', ['concurrent']);
};
