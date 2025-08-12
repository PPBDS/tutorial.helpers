// esbuild.js
const esbuild = require('esbuild');

const production = process.argv.includes('--production');
const watch = process.argv.includes('--watch');

// Problem matcher style logs
const esbuildProblemMatcherPlugin = {
  name: 'esbuild-problem-matcher',
  setup(build) {
    build.onStart(() => {
      if (watch) console.log('[watch] build started');
    });
    build.onEnd((result) => {
      for (const w of result.warnings || []) {
        const loc = w.location || {};
        console.warn(`⚠ [WARN] ${w.text}`);
        if (loc.file) console.warn(`    ${loc.file}:${loc.line || 0}:${loc.column || 0}`);
      }
      for (const e of result.errors || []) {
        const loc = e.location || {};
        console.error(`✘ [ERROR] ${e.text}`);
        if (loc.file) console.error(`    ${loc.file}:${loc.line || 0}:${loc.column || 0}`);
      }
      if (watch) console.log('[watch] build finished');
    });
  },
};

async function main() {
  const ctx = await esbuild.context({
    entryPoints: ['src/extension.ts'],
    outfile: 'dist/extension.js',
    bundle: true,
    platform: 'node',
    target: 'node18',
    format: 'cjs',
    minify: production,
    sourcemap: !production,
    sourcesContent: !production,            // keep sources in dev for easier debugging
    external: ['vscode'],                   // vscode must remain external for extensions
    logLevel: 'silent',                     // plugin handles pretty logging
    define: {
      'process.env.NODE_ENV': JSON.stringify(production ? 'production' : 'development'),
    },
    plugins: [esbuildProblemMatcherPlugin],
  });

  if (watch) {
    await ctx.watch();
    // Graceful shutdown on Ctrl+C
    process.on('SIGINT', async () => {
      await ctx.dispose();
      process.exit(0);
    });
  } else {
    const result = await ctx.rebuild();
    await ctx.dispose();
    if (result.errors?.length) process.exit(1);
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

