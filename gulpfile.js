'use strict';

var gulp = require('gulp'),
    // Remove time so nginx can serve the static assets.
    // now = new Date().getTime(),
    clean = require('gulp-clean'),
    sass = require('gulp-sass'),
    concat = require('gulp-concat');

var config = {
    sass: {
        includePaths: [
            'node_modules/govuk-frontend'
        ]
    },
    sassSrc: 'src/AppBundle/Resources/assets/scss',
    // webAssets: 'web/assets/' + now,
    webAssets: 'web/assets',
    jsSrc: 'src/AppBundle/Resources/assets/javascript',
    imgSrc: 'src/AppBundle/Resources/assets/images'
}

// Clean out old assets
gulp.task('clean', function () {
    return gulp.src('web/assets/*', {read: false})
        .pipe(clean());
});

// Compile sass files
gulp.task('sass', function () {
    return gulp.src([
            config.sassSrc + '/application.scss'])
        .pipe(sass(config.sass).on('error', sass.logError))
        .pipe(gulp.dest(config.webAssets + '/stylesheets'));
});

// Copy images and fonts from govuk frontend
gulp.task('govukImagesAndFonts', function () {
    return gulp.src('node_modules/govuk-frontend/assets/**/*')
        .pipe(gulp.dest(config.webAssets + '/'));
});

// Copy images
gulp.task('images', function () {
    return gulp.src(config.imgSrc + '/**/*')
        .pipe(gulp.dest(config.webAssets + '/images'));
});

// Concats js into application.js
gulp.task('js', function () {
    return gulp.src([
            'node_modules/govuk-frontend/all.js',
            config.jsSrc + '/main.js'])
        .pipe(concat('application.js'))
        .pipe(gulp.dest(config.webAssets + '/js'));
});

// Watch sass
gulp.task('watch', function () {
    gulp.watch([
        config.sassSrc + '/**/*.scss',
        config.sassSrc + '/*.scss',
        config.jsSrc + '/**/*.js',
        config.jsSrc + '/*.js'],
        { interval: 1000 },
        ['default']);
});

// Default task
gulp.task('default', ['clean','sass','govukImagesAndFonts','images','js']);