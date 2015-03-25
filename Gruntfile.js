module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('public/package.json'),
    nodewebkit: {
      options: {
        build_dir: './dist',
        // specifiy what to build
        mac: true,
        win: true,
        linux32: true,
        linux64: true
      },
      src: './public/**/*'
    },
  });

  grunt.loadNpmTasks('grunt-node-webkit-builder');

  grunt.registerTask('default', ['nodewebkit']);
};
