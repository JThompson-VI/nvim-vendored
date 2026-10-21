// Resolve from the application, including hoisted npm/pnpm dependencies.
const path = require('node:path');
const fs = require('node:fs');
const root = process.argv[2];
const result = {};
for (const name of ['vue', 'nuxt', 'typescript']) {
  try {
    const file = require.resolve(`${name}/package.json`, { paths: [root] });
    const pkg = JSON.parse(fs.readFileSync(file, 'utf8'));
    result[name] = { version: pkg.version, directory: path.dirname(file) };
  } catch (_) {
    // Dependencies might not have been installed yet.
  }
}
process.stdout.write(JSON.stringify(result));
