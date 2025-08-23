import prettier from 'prettier';
import htmlPlugin from 'prettier/plugins/html';
import yamlPlugin from 'prettier/plugins/yaml';
import babelPlugin from 'prettier/plugins/babel'
import flowPlugin from 'prettier/plugins/flow'
import typescriptPlugin from 'prettier/plugins/typescript'
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
    const { parserName, parser, tabWidth = 2, printWidth = 120, ...other } = options;
    // Use parserName if provided, otherwise fallback to parser
    const actualParser = parserName || parser;
    const entry = parserPluginMap[actualParser];
    if (!entry) throw new Error(`Unsupported parser: ${actualParser}`);

    // For HTML parsing, we need to include JavaScript plugins as well
    // to properly format embedded JavaScript code
    let plugins = [entry.plugin];
    
    if (actualParser === 'html' || actualParser === 'vue' || actualParser === 'angular' || actualParser === 'lwc') {
        // Add JavaScript plugins for embedded JavaScript formatting
        plugins.push(babelPlugin, typescriptPlugin, acornPlugin);
    }

    return prettier.format(value, {
        parser: actualParser,
        tabWidth,
        printWidth,
        plugins,
        ...other
    });
}

export default {
    format
};