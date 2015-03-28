module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('app/package.json'),
    nodewebkit: {
      options: {
        build_dir: './dist',
        // specifiy what to build
        mac: true,
        win: true,
        macIcns: 'app/images/logo.icns',
        winIco: 'app/images/logo.ico',
        linux32: true,
        linux64: true
      },
      src: './app/**/*'
    },
  });

  grunt.loadNpmTasks('grunt-node-webkit-builder');

  grunt.registerTask('default', ['nodewebkit']);
};
