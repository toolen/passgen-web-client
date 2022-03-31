const purgecss = require('@fullhuman/postcss-purgecss');

module.exports = {
    root: 'src',
    build: {
        outDir: '../dist'
    },
    css: {
        postcss: {
            plugins: [
                purgecss({
                    content: ['src/index.html']
                })
            ]
        }
    }
}