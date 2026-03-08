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

// i18n
const lang = process.env.INSTALLER_LANG === 'zh' ? 'zh' : 'en';

const t = {
  en: {
    intro:          ' OpenClaw Skills Installer ',
    noSkills:       `No skills found in ${SOURCE_DIR}`,
    selectPrompt:   'Select skills to install',
    installed:      'installed',
    overwrite:      '(overwrite)',
    willInstall:    'Will install',
    proceed:        'Proceed?',
    nothingSelected:'Nothing selected.',
    cancelled:      'Cancelled.',
    installing:     'Installing...',
    done:           'Done',
    results:        'Results',
    outroOk:        n => `${n} skill(s) installed successfully`,
    outroFail:      (s, f) => `Installed: ${s}  Failed: ${f}`,
    cliInstalling:  n => `Installing ${n} skill(s)...`,
  },
  zh: {
    intro:          ' OpenClaw Skills 安装器 ',
    noSkills:       `在 ${SOURCE_DIR} 中未找到任何 skill`,
    selectPrompt:   '选择要安装的 skills',
    installed:      '已安装',
    overwrite:      '(将覆盖)',
    willInstall:    '将要安装',
    proceed:        '确认安装?',
    nothingSelected:'未选择任何内容。',
    cancelled:      '已取消。',
    installing:     '安装中...',
    done:           '完成',
    results:        '安装结果',
    outroOk:        n => `成功安装 ${n} 个 skill`,
    outroFail:      (s, f) => `成功: ${s}  失败: ${f}`,
    cliInstalling:  n => `正在安装 ${n} 个 skill...`,
  },
}[lang];

// Helpers

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

function installAll(names) {
  const results = [];
  for (const name of names) {
    try {
      installSkill(name);
      results.push({ name, ok: true });
    } catch (err) {
      results.push({ name, ok: false, err: err.message });
    }
  }
  return results;
}

function logResults(results) {
  for (const { name, ok, err } of results) {
    if (ok) {
      p.log.success(name);
    } else {
      p.log.error(`${name}: ${color.dim(err)}`);
    }
  }
}

// Interactive mode

async function runInteractive() {
  p.intro(color.bgCyan(color.black(t.intro)));

  mkdirSync(TARGET_DIR, { recursive: true });

  const skills = getSkills();
  if (skills.length === 0) {
    p.cancel(t.noSkills);
    process.exit(1);
  }

  const selected = await p.multiselect({
    message: t.selectPrompt,
    options: skills.map(name => ({
      value: name,
      label: name,
      hint: isInstalled(name) ? color.cyan(t.installed) : '',
    })),
    required: false,
  });

  if (p.isCancel(selected) || selected.length === 0) {
    p.cancel(t.nothingSelected);
    process.exit(0);
  }

  p.log.step(t.willInstall);
  for (const name of selected) {
    const suffix = isInstalled(name) ? `  ${color.yellow(t.overwrite)}` : '';
    p.log.info(`${name}${suffix}`);
  }

  const ok = await p.confirm({ message: t.proceed });
  if (p.isCancel(ok) || !ok) {
    p.cancel(t.cancelled);
    process.exit(0);
  }

  const s = p.spinner();
  s.start(t.installing);
  const results = installAll(selected);
  const success = results.filter(r => r.ok).length;
  const failed  = results.filter(r => !r.ok).length;
  s.stop(failed > 0 ? t.outroFail(success, failed) : t.outroOk(success));

  logResults(results);

  if (failed > 0) {
    p.outro(color.yellow(t.outroFail(success, failed)));
  } else {
    p.outro(color.green(t.outroOk(success)));
  }
}

// CLI mode

async function runCli(names) {
  p.intro(color.bgCyan(color.black(t.intro)));

  mkdirSync(TARGET_DIR, { recursive: true });

  const s = p.spinner();
  s.start(t.cliInstalling(names.length));
  const results = installAll(names);
  const success = results.filter(r => r.ok).length;
  const failed  = results.filter(r => !r.ok).length;
  s.stop(failed > 0 ? t.outroFail(success, failed) : t.outroOk(success));

  logResults(results);

  if (failed > 0) {
    p.outro(color.yellow(t.outroFail(success, failed)));
  } else {
    p.outro(color.green(t.outroOk(success)));
  }
}

// Entry point

const args = process.argv.slice(2);
const run = args.length > 0 ? runCli(args) : runInteractive();
run.catch(err => { console.error(err); process.exit(1); });
