import globals from "globals";
import babelParser from "@babel/eslint-parser";
import path from "node:path";
import { fileURLToPath } from "node:url";
import js from "@eslint/js";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
    baseDirectory: __dirname,
    recommendedConfig: js.configs.recommended,
    allConfig: js.configs.all
});

export default [{
    ignores: [
        "**/node_modules",
        "**/.gitignore",
        "**/tmp",
        "**/vendor",
        "**/public",
        "**/docs",
        "**/solr",
    ],
}, ...compat.extends("plugin:prettier/recommended"), {
    languageOptions: {
        globals: {
            ...globals.browser,
            ...globals.node,
            ...globals.jquery,
        },

        parser: babelParser,
    },

    rules: {
        "prefer-const": "error",

        "no-trailing-spaces": ["error", {
            skipBlankLines: true,
            ignoreComments: true,
        }],

        "arrow-body-style": "off",
        "prefer-arrow-callback": "off",
        "no-unused-vars": "warn",
    },
}, {
    files: ["**/*.spec.js", "**/*.spec.jsx"],

    languageOptions: {
        globals: {
            ...globals.jest,
        },
    },
}];