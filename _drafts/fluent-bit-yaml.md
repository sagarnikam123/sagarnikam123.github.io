---
title: "Fluent Bit YAML Configuration Guide"
description: "Complete guide to configuring Fluent Bit using YAML format. Learn about inputs, outputs, filters, parsers, and plugin properties for log processing"
author: sagarnikam123
date: 2025-11-17 12:00:00 +0530
categories: [devops, logging, observability]
tags: [fluent-bit, yaml, logging, log-processing, observability]
mermaid: true
---

### Plugin properties

#### tail plugin properties

```bash
path, exclude_path, key, read_from_head, read_newly_discovered_files_from_head, refresh_interval, watcher_interval, progress_check_interval, progress_check_interval_nsec, rotate_wait, docker_mode, docker_mode_flush, docker_mode_parser, path_key, offset_key, ignore_older, ignore_active_older_files, buffer_chunk_size, buffer_max_size, static_batch_size, event_batch_size, skip_long_lines, exit_on_eof, skip_empty_lines, file_cache_advise, inotify_watcher, parser, tag_regex, db, db.sync, db.locking, db.journal_mode, db.compare_filename, multiline, multiline_flush, parser_firstline, parser_, multiline.parser, unicode.encoding, generic.encoding
```
