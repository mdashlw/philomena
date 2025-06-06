import jsEslint from '@eslint/js';
import tsEslint from 'typescript-eslint';
import vitestPlugin from '@vitest/eslint-plugin';
import globals from 'globals';

export default tsEslint.config(
  // Standard configs as per the docs to get the strictest linting possible.
  // https://typescript-eslint.io/users/configs#projects-with-type-checking
  jsEslint.configs.recommended,
  tsEslint.configs.strict,
  tsEslint.configs.stylistic,

  // Custom tweaks on top of the standard recommended configs
  {
    name: 'PhilomenaConfig',
    languageOptions: {
      globals: {
        ...globals.browser,
      },
    },
    rules: {
      'accessor-pairs': 2,
      'array-callback-return': 2,
      'block-scoped-var': 2,
      camelcase: [2, { allow: ['camo_url', 'spoiler_image_uri', 'image_ids'] }],
      'class-methods-use-this': 0,
      complexity: 0,
      'consistent-return': 0,
      'consistent-this': [2, 'that'],
      'constructor-super': 2,
      curly: [2, 'multi-line', 'consistent'],
      'default-case': 2,
      'dot-notation': [2, { allowKeywords: true }],
      eqeqeq: 2,
      'func-name-matching': 2,
      'func-names': 0,
      'func-style': 0,
      'guard-for-in': 0,
      'id-length': 0,
      'id-match': 2,
      'init-declarations': 0,
      'max-depth': 0,
      'max-lines': 0,
      'max-nested-callbacks': 0,
      'max-params': 0,
      'max-statements': 0,
      'new-cap': 2,
      'no-alert': 0,
      'no-array-constructor': 2,
      'no-caller': 2,
      'no-case-declarations': 2,
      'no-class-assign': 2,
      'no-cond-assign': 2,
      'no-console': 0,
      'no-const-assign': 2,
      'no-constant-condition': 2,
      'no-control-regex': 2,
      'no-debugger': 2,
      'no-delete-var': 2,
      'no-div-regex': 2,
      'no-dupe-args': 2,
      'no-dupe-class-members': 2,
      'no-dupe-keys': 2,
      'no-duplicate-case': 2,
      'no-duplicate-imports': 2,
      'no-else-return': 2,
      'no-empty-character-class': 2,
      'no-empty-pattern': 2,
      'no-empty': 2,
      'no-eq-null': 2,
      'no-eval': 2,
      'no-ex-assign': 2,
      'no-extend-native': 2,
      'no-extra-bind': 2,
      'no-extra-boolean-cast': 2,
      'no-extra-label': 2,
      'no-fallthrough': 2,
      'no-func-assign': 2,
      'no-global-assign': 2,
      'no-implicit-coercion': 2,
      'no-implicit-globals': 2,
      'no-implied-eval': 2,
      'no-inline-comments': 0,
      'no-inner-declarations': [2, 'both'],
      'no-invalid-regexp': 2,
      'no-invalid-this': 2,
      'no-irregular-whitespace': 2,
      'no-iterator': 2,
      'no-label-var': 2,
      'no-labels': [2, { allowSwitch: true, allowLoop: true }],
      'no-lone-blocks': 2,
      'no-lonely-if': 0,
      'no-loop-func': 2,
      'no-magic-numbers': 0,
      'no-multi-str': 2,
      'no-negated-condition': 0,
      'no-nested-ternary': 2,
      'no-new-func': 2,
      'no-new-wrappers': 2,
      'no-new': 2,
      'no-obj-calls': 2,
      'no-object-constructor': 2,
      'no-octal-escape': 2,
      'no-octal': 2,
      'no-param-reassign': 2,
      'no-plusplus': 0,
      'no-proto': 2,
      'no-prototype-builtins': 0,
      'no-regex-spaces': 2,
      'no-restricted-globals': [2, 'event'],
      'no-restricted-imports': 2,
      'no-restricted-properties': 0,
      'no-restricted-syntax': 2,
      'no-return-assign': 0,
      'no-script-url': 2,
      'no-self-assign': 2,
      'no-self-compare': 2,
      'no-sequences': 2,
      'no-shadow-restricted-names': 2,
      'no-sparse-arrays': 2,
      'no-template-curly-in-string': 2,
      'no-ternary': 0,
      'no-this-before-super': 2,
      'no-throw-literal': 2,
      'no-undef-init': 2,
      'no-undefined': 0,
      'no-underscore-dangle': 0,
      'no-unexpected-multiline': 2,
      'no-unmodified-loop-condition': 2,
      'no-unneeded-ternary': 2,
      'no-unreachable': 2,
      'no-unsafe-finally': 2,
      'no-unsafe-negation': 2,
      'no-unused-labels': 2,
      'no-use-before-define': [2, 'nofunc'],
      'no-useless-call': 2,
      'no-useless-computed-key': 2,
      'no-useless-concat': 2,
      'no-useless-constructor': 2,
      'no-useless-escape': 2,
      'no-useless-rename': 2,
      'no-var': 2,
      'no-void': 2,
      'no-warning-comments': 0,
      'no-with': 2,
      'object-shorthand': 2,
      'one-var': 0,
      'operator-assignment': [2, 'always'],
      'prefer-arrow-callback': 2,
      'prefer-const': 2,
      'prefer-numeric-literals': 2,
      'prefer-rest-params': 2,
      'prefer-spread': 0,
      'prefer-template': 2,
      radix: 2,
      'require-jsdoc': 0,
      'require-yield': 2,
      'sort-imports': 0,
      'sort-keys': 0,
      'sort-vars': 0,
      strict: [2, 'function'],
      'symbol-description': 2,
      'unicode-bom': 2,
      'use-isnan': 2,
      'valid-jsdoc': 0,
      'valid-typeof': 2,
      'vars-on-top': 2,
      yoda: [2, 'never'],

      // TODO: replace all non-null assertions with explicit errors
      '@typescript-eslint/no-non-null-assertion': 0,

      // Not very useful. An empty function is sometimes passed where the api
      // requires some function, but we have nothing to do in it.
      '@typescript-eslint/no-empty-function': 0,

      // Make it possible to ignore unused variables with `_` prefix
      '@typescript-eslint/no-unused-vars': [
        2,
        {
          vars: 'all',
          args: 'all',
          varsIgnorePattern: '^_',
          argsIgnorePattern: '^_',
        },
      ],

      // For some reason `@typescript-eslint/no-shadown` doesn't disable the
      // default eslint's rule (`no-shadow`) like other typescript rules
      'no-shadow': 0,
      '@typescript-eslint/no-shadow': 2,
    },
    ignores: ['js/vendor/*', 'vite.config.ts'],
  },
  {
    name: 'Tests',
    files: ['**/*.spec.ts', '**/test/*.ts'],
    plugins: {
      vitest: vitestPlugin,
    },
    rules: {
      ...vitestPlugin.configs.recommended.rules,
      'vitest/valid-expect': 0,
      'vitest/expect-expect': [
        'error',
        {
          // Custom `expectStuff()` functions must also count as assertions.
          assertFunctionNames: ['expect*', '*.expect*', 'assert*'],
        },
      ],
    },
  },
);
