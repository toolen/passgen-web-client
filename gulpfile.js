const { series, src, dest, watch, parallel } = require('gulp');
const uglify = require('gulp-uglify');
const rename = require('gulp-rename');
const csso = require('gulp-csso');
const purgecss = require('gulp-purgecss');
const concat = require('gulp-concat');
const browserSync = require('browser-sync').create();
const del = require('del');
const htmlmin = require('gulp-htmlmin');

const source = 'src';
const dist = 'dist';
const paths = {
    dist,
    src: source,
    index: `${source}/index.html`,
    styles: `${source}/css/**/*.css`,
    scripts: `${source}/js/**/*.js`,
}

const clean = () => del([`${paths.dist}`]);

function css() {
    return src([
        'node_modules/awsm.css/dist/awsm.css',
        paths.styles
    ])
    .pipe(concat('style.css'))
    .pipe(purgecss({
        content: [paths.index]
    }))
    .pipe(csso())
    .pipe(rename({ basename: 'style', extname: '.min.css' }))
    .pipe(dest(`${paths.dist}/css`));
}

function js() {
    return src(paths.scripts)
    .pipe(uglify())
    .pipe(rename({ extname: '.min.js' }))
    .pipe(dest(`${paths.dist}/js`));
}

function html() {
    return src(paths.index)
    .pipe(htmlmin({
        collapseWhitespace: true,
        removeComments: true
    }))
    .pipe(dest(`${paths.dist}/`));
}

function reload(done) {
    browserSync.reload();
    done();
}

function serve(done) {
    browserSync.init({
        server: {
            baseDir: `./${paths.dist}`,
            https: {
                key: "./key.pem",
                cert: "./cert.pem"
            }
        }
    });

}

function observe() {
    watch(paths.scripts, series(js, reload));
    watch(paths.styles, series(css, reload));
    watch(paths.index, series(html, reload));
}

const build = series(clean, parallel(js, css, html));

exports.dev = series(clean, js, css, html, parallel(serve, observe));
exports.build = build;
exports.default = build;