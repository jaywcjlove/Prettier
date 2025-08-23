import { nodeResolve } from "@rollup/plugin-node-resolve";
import terser from '@rollup/plugin-terser';
import sizes from 'rollup-plugin-sizes';
import nodePolyfills from 'rollup-plugin-polyfill-node';
import commonjs from '@rollup/plugin-commonjs';

export default {
    input: "./prettier.js",
    output: {
        file: "../Sources/Prettier/Resources/prettier.bundle.min.js",
        name: "Prettier",
        format: "iife",
        inlineDynamicImports: true,
    },
    plugins: [
        nodeResolve({
            browser: true,
            preferBuiltins: false
        }),
        commonjs(),
        nodePolyfills({
            exclude: ['fs', 'path', 'crypto', 'stream'] // 排除 JavaScript Core 不需要的模块
        }),
        // terser(),
        // terser({
        //     compress: {
        //         drop_console: true,
        //         drop_debugger: true,
        //         pure_funcs: ['console.log', 'console.info', 'console.debug', 'console.warn'],
        //         passes: 3
        //     },
        //     mangle: {
        //         toplevel: true
        //     }
        // }),
        sizes()
    ],
};
