module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('app/package.json'),
    nodewebkit: {
      options: {
        version: '0.12.2',
        build_dir: './dist',
        // specifiy what to build
        mac: true,
        win: true,
        macIcns: 'app/images/logo.icns',
        winIco: 'app/images/logo.ico',
        linux32: true,
        linux64: true
      },
      src: ['./app/**/*', '!./app/data/**/*', '!./app/config.json']
    },
  });

  grunt.loadNpmTasks('grunt-node-webkit-builder');

  grunt.registerTask('default', ['nodewebkit']);
};
