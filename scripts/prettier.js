import prettier from 'prettier';
import htmlPlugin from 'prettier/plugins/html';
import yamlPlugin from 'prettier/plugins/yaml';
import babelPlugin from 'prettier/plugins/babel'
import flowPlugin from 'prettier/plugins/flow'
import typescriptPlugin from 'prettier/plugins/typescript'
import estreePlugin from 'prettier/plugins/estree'
import acornPlugin from 'prettier/plugins/acorn'
import meriyahPlugin from 'prettier/plugins/meriyah'
import postcssPlugin from 'prettier/plugins/postcss'
import graphqlPlugin from 'prettier/plugins/graphql'
import markdownPlugin from 'prettier/plugins/markdown'
import glimmerPlugin from 'prettier/plugins/glimmer'

const parserPluginMap = {
    acorn: { plugin: acornPlugin },
    angular: { plugin: htmlPlugin },
    "babel-flow": { plugin: babelPlugin },
    "babel-ts": { plugin: babelPlugin },
    babel: { plugin: babelPlugin },
    css: { plugin: postcssPlugin },
    espree: { plugin: acornPlugin },
    flow: { plugin: flowPlugin },
    graphql: { plugin: graphqlPlugin },
    glimmer: { plugin: glimmerPlugin },
    html: { plugin: htmlPlugin },
    "json-stringify": { plugin: babelPlugin },
    json: { plugin: babelPlugin },
    json5: { plugin: babelPlugin },
    jsonc: { plugin: babelPlugin },
    lwc: { plugin: htmlPlugin },
    less: { plugin: postcssPlugin },
    markdown: { plugin: markdownPlugin },
    mdx: { plugin: markdownPlugin },
    meriyah: { plugin: meriyahPlugin },
    mjml: { plugin: htmlPlugin },
    scss: { plugin: postcssPlugin },
    typescript: { plugin: typescriptPlugin },
    vue: { plugin: htmlPlugin },
    yaml: { plugin: yamlPlugin },
    remark: { plugin: markdownPlugin },
};

function format(value, options = {}) {
    const { parser, tabWidth = 2, printWidth = 120, ...other } = options;
    const entry = parserPluginMap[parser];
    if (!entry) throw new Error(`Unsupported parser: ${parser}`);
    // For HTML parsing, we need to include JavaScript plugins as well
    // to properly format embedded JavaScript code
    let plugins = [entry.plugin, estreePlugin];
    if (parser === 'html' || parser === 'vue' || parser === 'angular' || parser === 'lwc') {
        // Add JavaScript and CSS plugins for embedded code formatting
        plugins.push(babelPlugin, typescriptPlugin, acornPlugin, postcssPlugin);
    }

    return prettier.format(value, {
        parser: parser,
        tabWidth,
        printWidth,
        plugins,
        ...other
    });
}

export default {
    format
};
