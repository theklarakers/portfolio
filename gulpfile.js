var gulp = require('gulp');
var sass = require('gulp-sass');
var browserSync = require('browser-sync').create();
var header = require('gulp-header');
var cleanCSS = require('gulp-clean-css');
var rename = require("gulp-rename");
var uglify = require('gulp-uglify');
var pkg = require('./package.json');

// Set the banner content
var banner = ['/*!\n',
  ' * <%= pkg.title %> v<%= pkg.version %> (<%= pkg.homepage %>)\n',
  ' * Copyright 2017-' + (new Date()).getFullYear(), ' <%= pkg.author %>\n',
  ' * Licensed under <%= pkg.license %> (https://github.com/theklarakers/<%= pkg.name %>/blob/master/LICENSE)\n',
  ' */\n',
  ''
].join('');

// Compiles SCSS files from /scss into /css
gulp.task('sass', function() {
  return gulp.src('scss/grayscale.scss')
    .pipe(sass())
    .pipe(header(banner, {
      pkg: pkg
    }))
    .pipe(gulp.dest('css'))
    .pipe(browserSync.reload({
      stream: true
    }))
});

// Minify compiled CSS
gulp.task('minify-css', ['sass'], function() {
  return gulp.src('css/grayscale.css')
    .pipe(cleanCSS({
      compatibility: 'ie8'
    }))
    .pipe(rename({
      suffix: '.min'
    }))
    .pipe(gulp.dest('css'))
    .pipe(browserSync.reload({
      stream: true
    }))
});

// Minify custom JS
gulp.task('minify-js', function() {
  return gulp.src('js/grayscale.js')
    .pipe(uglify())
    .pipe(header(banner, {
      pkg: pkg
    }))
    .pipe(rename({
      suffix: '.min'
    }))
    .pipe(gulp.dest('js'))
    .pipe(browserSync.reload({
      stream: true
    }))
});

// Copy vendor files from /node_modules into /vendor
// NOTE: requires `npm install` before running!
gulp.task('copy', function() {
  gulp.src([
      'node_modules/bootstrap/dist/**/*',
      '!**/npm.js',
      '!**/bootstrap-theme.*',
      '!**/*.map'
    ])
    .pipe(gulp.dest('vendor/bootstrap'))

  gulp.src(['node_modules/jquery/dist/jquery.js', 'node_modules/jquery/dist/jquery.min.js'])
    .pipe(gulp.dest('vendor/jquery'))

  gulp.src(['node_modules/jquery.easing/*.js'])
    .pipe(gulp.dest('vendor/jquery-easing'))

  return gulp.src([
      'node_modules/font-awesome/**',
      '!node_modules/font-awesome/**/*.map',
      '!node_modules/font-awesome/.npmignore',
      '!node_modules/font-awesome/*.txt',
      '!node_modules/font-awesome/*.md',
      '!node_modules/font-awesome/*.json'
    ])
    .pipe(gulp.dest('vendor/font-awesome'))
})

// Default task
gulp.task('default', ['sass', 'minify-css', 'minify-js', 'copy']);

// Configure the browserSync task
gulp.task('browserSync', function() {
  browserSync.init({
    server: {
      baseDir: 'build',
    },
    host: '0.0.0.0'
  })
});

// Dev task with browserSync
gulp.task('dev', ['browserSync', 'sass', 'minify-css', 'minify-js', 'copy', 'move'], function() {
  gulp.watch('scss/*.scss', ['sass', 'move']);
  gulp.watch('css/*.css', ['minify-css', 'move']);
  gulp.watch('js/*.js', ['minify-js', 'move']);
  gulp.watch('*.html', ['move']);
  // Reloads the browser whenever HTML, SCSS, CSS or JS files change
  gulp.watch('*.html', browserSync.reload);
  gulp.watch('js/**/*.js', browserSync.reload);
  gulp.watch('css/*.css', browserSync.reload);
  gulp.watch('scss/*.scss', browserSync.reload);
});

gulp.task('build', ['sass', 'minify-css', 'minify-js', 'copy'], function() {
    gulp.src(['vendor/**/*']).pipe(gulp.dest('build/vendor'));
    gulp.src(['css/**/*']).pipe(gulp.dest('build/css'));
    gulp.src(['js/**/*']).pipe(gulp.dest('build/js'));
    gulp.src(['img/**/*']).pipe(gulp.dest('build/img'));
    gulp.src('index.html').pipe(gulp.dest('build/'));
});

gulp.task('move', [], function() {
    gulp.src(['vendor/**/*']).pipe(gulp.dest('build/vendor'));
    gulp.src(['css/**/*']).pipe(gulp.dest('build/css'));
    gulp.src(['js/**/*']).pipe(gulp.dest('build/js'));
    gulp.src(['img/**/*']).pipe(gulp.dest('build/img'));
    gulp.src('index.html').pipe(gulp.dest('build/'));
});
