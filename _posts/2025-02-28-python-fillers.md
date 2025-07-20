---
date: 2025-02-28 12:00:00 +0530
layout: post
title: "Python fillers (draft)"
description: "imp code snippets used during fast programming"
categories: [python]
tags: [logging, snippet]
---

### Logging

##### simple logging on terminal
```
import logging

logging.basicConfig(format='%(asctime)s %(levelname)-1s: [%(lineno)d] %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S', encoding='utf-8', level=logging.INFO)
logger = logging.getLogger(__name__)
logger.propagate = True

logger.info("Hello World!")
```
