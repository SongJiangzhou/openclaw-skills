#!/usr/bin/env node

import * as p from '@clack/prompts';
import color from 'picocolors';
import { readdirSync, existsSync, mkdirSync, rmSync, symlinkSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { homedir } from 'os';

const __dirname = dirname(fileURLToPath(import.meta.url));
const SOURCE_DIR = join(__dirname, 'skills');
const TARGET_DIR = join(homedir(), '.openclaw', 'workspace', 'skills');

function getSkills() {
  return readdirSync(SOURCE_DIR, { withFileTypes: true })
    .filter(d => d.isDirectory())
    .map(d => d.name)
    .sort();
}

function isInstalled(name) {
  return existsSync(join(TARGET_DIR, name));
}

function installSkill(name) {
  const src = join(SOURCE_DIR, name);
  const dst = join(TARGET_DIR, name);
  if (existsSync(dst)) rmSync(dst, { recursive: true, force: true });
  symlinkSync(src, dst);
}

async function runInteractive() {
  p.intro(color.bgCyan(color.black(' OpenClaw Skills Installer ')));

  mkdirSync(TARGET_DIR, { recursive: true });

  const skills = getSkills();
  if (skills.length === 0) {
    p.cancel(`No skills found in ${SOURCE_DIR}`);
    process.exit(1);
  }

  const selected = await p.multiselect({
    message: 'Select skills to install',
    options: skills.map(name => ({
      value: name,
      label: name,
      hint: isInstalled(name) ? color.cyan('installed') : '',
    })),
    required: false,
  });

  if (p.isCancel(selected) || selected.length === 0) {
    p.cancel('Nothing selected.');
    process.exit(0);
  }

  // Show what will happen
  const lines = selected.map(name =>
    isInstalled(name)
      ? `  ${color.green('✓')} ${name}  ${color.yellow('(overwrite)')}`
      : `  ${color.green('✓')} ${name}`
  );
  p.note(lines.join('\n'), 'Will install');

  const ok = await p.confirm({ message: 'Proceed?' });
  if (p.isCancel(ok) || !ok) {
    p.cancel('Cancelled.');
    process.exit(0);
  }

  // Install
  const s = p.spinner();
  s.start('Installing...');

  let success = 0;
  let failed = 0;
  const results = [];

  for (const name of selected) {
    try {
      installSkill(name);
      results.push(`  ${color.green('✓')} ${name}`);
      success++;
    } catch (err) {
      results.push(`  ${color.red('✗')} ${name}  ${color.dim(err.message)}`);
      failed++;
    }
  }

  s.stop('Done');

  p.note(results.join('\n'), 'Results');

  if (failed > 0) {
    p.outro(color.yellow(`Installed: ${success}  Failed: ${failed}`));
  } else {
    p.outro(color.green(`${success} skill(s) installed successfully`));
  }
}

async function runCli(names) {
  p.intro(color.bgCyan(color.black(' OpenClaw Skills Installer ')));

  mkdirSync(TARGET_DIR, { recursive: true });

  const s = p.spinner();
  s.start(`Installing ${names.length} skill(s)...`);

  let success = 0;
  let failed = 0;
  const results = [];

  for (const name of names) {
    try {
      installSkill(name);
      results.push(`  ${color.green('✓')} ${name}`);
      success++;
    } catch (err) {
      results.push(`  ${color.red('✗')} ${name}  ${color.dim(err.message)}`);
      failed++;
    }
  }

  s.stop('Done');

  p.note(results.join('\n'), 'Results');

  if (failed > 0) {
    p.outro(color.yellow(`Installed: ${success}  Failed: ${failed}`));
  } else {
    p.outro(color.green(`${success} skill(s) installed successfully`));
  }
}

// Entry point
const args = process.argv.slice(2);
if (args.length > 0) {
  runCli(args).catch(err => { console.error(err); process.exit(1); });
} else {
  runInteractive().catch(err => { console.error(err); process.exit(1); });
}
