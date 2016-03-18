// Gruntfile
module.exports = function(grunt) {
require('load-grunt-tasks')(grunt);

  // Project configuration.
  grunt.initConfig({

    pkg: grunt.file.readJSON('package.json'),

    watch: {
      css: {
        files: ['_sass/**/*.scss'],
        tasks: ['sass', 'postcss', 'shell:jekyllBuild'],
        options: {
          atBegin: true
        }
      },
      jekyll: {
        files: ['index.md', '_includes/*.html', 'filters/*.*',  '_layouts/*.*', 'tags/*.*', 'basics/*.*'],
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
          require('autoprefixer-core')({browsers: 'last 2 versions'})
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

  grunt.registerTask('default', ['concurrent']);
};
