# Symfony Docker Installer v.2.0

## About

- Symfony (version defined interactively)
- PHP-FPM 8.4
- MySQL 8
- nginx (latest)

## Quick Start

### 1. Init project
Copy the `.env.install.dist` file to `.env.install`

Change the `PROJECT_NAME` variable in `.env.install`,
and any other variables if needed

### 2. Run installer

```bash
make install-init
```

This will launch an interactive installation wizard with Symfony version selection, optional Git initialization, and create a new project in the `./install` folder.

### 3. Profit

See all available make targets in [Makefile.md](Makefile.md)

You can define your own commands in [MakefileCustom](MakefileCustom)