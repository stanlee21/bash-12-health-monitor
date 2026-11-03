# System Health Monitor

## Problem Statement

System resources such as disk space, memory, and CPU load can become overloaded without users noticing. This can affect system performance and cause unexpected failures.

## Project Goals

Build a Bash-based system monitoring tool that checks important system resources, detects potential issues, records monitoring results, and automates health checks.

## Tech Stack

- Bash
- Linux
- ShellCheck
- AWK
- Cron

## Features

- Monitors root filesystem disk usage.
- Checks system memory consumption.
- Measures system load against available CPU cores.
- Configurable warning thresholds through environment variables.
- Displays `OK` or `WARN` for each resource.
- Logs monitoring results to `~/logs/health.log`.
- Supports quiet mode with `--quiet`.
- Returns appropriate exit codes.
- Runs automatically every 15 minutes using cron.
- Can be executed globally using the `health` command.

### Screenshots

![alt text](<screenshots/Screenshot From 2026-11-03 18-03-23.png>)

![alt text](<screenshots/Screenshot From 2026-11-03 18-04-28.png>)

![alt text](<screenshots/Screenshot From 2026-11-03 18-05-16.png>)

### Global Installation

Create the local binary directory:

```bash
mkdir -p ~/.local/bin
```

Create a symbolic link to the health monitor:

```bash
ln -sfn "$PWD/health.sh" ~/.local/bin/health
```

Add the directory to PATH:

```bash
grep -q 'local/bin' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

The monitor can now be executed from any directory:

```bash
health
```

### Automated Monitoring with Cron

Add this entry to your crontab:

```bash
*/15 * * * * $HOME/.local/bin/health --quiet
```

This executes the health monitor every 15 minutes without displaying terminal output. Results are saved to:

```text
~/logs/health.log
```

View the monitoring history:

```bash
tail -10 ~/logs/health.log
```

View scheduled jobs:

```bash
crontab -l
```

## Author

**Tata Stanley Mbajing**
Frontend Developer
Email: [stanleymbajingtata@gmail.com]
