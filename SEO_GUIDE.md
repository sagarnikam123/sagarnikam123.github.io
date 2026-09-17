# SEO & Front Matter Guide for Jekyll Chirpy

This document defines the SEO standards, taxonomy rules, and front matter guidelines for **sagarnikam123.github.io** powered by the **Jekyll Chirpy** theme. Follow these principles whenever creating or updating posts and drafts.

---

## 1. Post File Naming & URL Structure

Jekyll Chirpy automatically generates the canonical URL permalink from the post's filename:

- **Location:** `_posts/YYYY-MM-DD-title-slug.md` (or `_drafts/title-slug.md` during drafting).
- **Format:** Lowercase words separated by hyphens (e.g., `2026-09-17-linux-commands-cheat-sheet.md`).
- **URL Output:** Maps to `https://sagarnikam123.github.io/posts/title-slug/`.
- **Slug SEO:** Keep the slug concise (3–6 words) containing the primary target keyword. Avoid filler words (`and`, `the`, `of`) in filenames.

---

## 2. Anatomy of a Perfect Chirpy Front Matter

```yaml
---
title: "Primary Keyword First: Engaging Title Under 60 Characters"
description: "Actionable summary between 130 and 155 characters that naturally includes secondary search terms for search engine snippet preview."
author: sagarnikam123
date: 2026-09-17 12:00:00 +0530
categories: [PrimaryPillar, SubCategory]
tags: [primary-keyword, secondary-search-term, specific-tool-name, relevant-concept]
pin: false        # Set true to pin post to the top of homepage (max 2-3)
toc: true         # Set true (default) to generate sticky right-rail table of contents
mermaid: true     # Set true ONLY if post contains mermaid code diagrams
math: true        # Set true ONLY if post contains LaTeX math expressions
image:
  path: assets/img/posts/YYYYMMDD/descriptive-filename.webp
  lqip: data:image/webp;base64,...
  alt: Descriptive image alt text targeting image search SEO
---
```

---

## 3. Field-by-Field SEO Rules

### `title:` (Page Title & `<h1>`)

- **Length:** 50–60 characters (titles over 60 characters get truncated in Google SERPs).
- **Placement:** Front-load the primary search keyword within the first 3–5 words.
- **Tone:** Problem-solving, authoritative, and click-worthy without clickbait.
- **Rule:** Do **not** repeat the site name in `title:` — Chirpy and `jekyll-seo-tag` automatically append `| Sagar Nikam`.

### `description:` (Meta Description & Open Graph Snippet)

- **Length:** **130–155 characters** (Strict ceiling: 160 characters).
- **Function:** Feeds `<meta name="description">` and `og:description`. Google truncates anything above 160 characters with `...`.
- **Content:** Include a direct answer, benefit statement, and a soft call-to-action (e.g., *“Complete tutorial with architecture diagrams and benchmarks.”*).

### `categories:` (Chirpy Two-Tier Architecture)

- **Strict Chirpy Constraint:** Always use **exactly two levels**: `[PrimaryCategory, SubCategory]`.
  ```yaml
  # ✅ CORRECT:
  categories: [Observability, Logging]
  categories: [Programming, Python]
  categories: [DevOps, Ansible]

  # ❌ INCORRECT (Breaks Chirpy UI accordion & creates thin archive traps):
  categories: [DevOps]                          # Only 1 level
  categories: [DevOps, Automation, Ansible]     # 3 levels (Chirpy only supports 2)
  categories: [devops, ansible]                 # lowercase (use PascalCase)
  ```
- **Why?** Chirpy's `_layouts/categories.html` renders an accordion with a parent and child tier. Adding 3 or more levels creates broken visual nesting and dilutes topical authority.
- **Pillar Consistency:** Map every post into one of the **Core Topic Pillars** (see Section 4).

### `tags:` (Search Keywords & Topical Clustering)

- **Quantity:** 4–6 targeted keywords per post.
- **Format:** Lowercase `kebab-case` only (e.g., `open-source-observability`, `datadog-alternatives`).
- **Never use `keywords:`:**
  > [!IMPORTANT]
  > `jekyll-seo-tag` does **not** recognize a `keywords:` frontmatter key. Furthermore, Google and Bing have ignored `<meta name="keywords">` for over 15 years. Always use Chirpy's native `tags:` array.
- **Search Intent:** Combine:
  1. Primary head keyword (e.g., `linux-troubleshooting-commands`)
  2. High-intent variant (e.g., `systemd-monitoring`)
  3. Tool/technology name (e.g., `htop`, `journalctl`)
  4. Content format (e.g., `cheatsheet`, `tutorial`, `benchmarks`)

### `image:` (Visual SEO & Social Previews)

- Always specify `alt:` text with keyword context for Google Images.
- Use modern `.webp` formats with LQIP (Low Quality Image Placeholder) base64 strings to maintain lightning-fast Core Web Vitals (LCP/FID).

---

## 4. Approved Category Taxonomy (The Core Pillars)

To avoid "thin content" penalties where Google crawls categories with only 1 post, strictly adhere to this pre-established pillar hierarchy:

| Primary Pillar (Level 1) | Approved Sub-Categories (Level 2) | Topic Scope |
| --- | --- | --- |
| **`Observability`** | `Platforms`, `Logging`, `Metrics`, `Tracing`, `Profiling`, `Benchmarks`, `Pricing`, `APM`, `Security`, `Landscape` | Monitoring, Grafana, OpenTelemetry, SigNoz, Vector, Loki |
| **`DevOps`** | `Ansible`, `Kafka`, `Testing`, `Setup`, `Automation`, `CI-CD` | Infrastructure as code, pipelines, Playwright, message brokers |
| **`Linux`** | `Commands`, `Troubleshooting`, `Setup`, `Administration` | CLI workflows, sysadmin one-liners, kernel tuning, distros |
| **`Programming`** | `Go`, `Python`, `R`, `C-Cpp`, `Git`, `Markdown`, `Coding-Challenges`, `Web-Development` | Syntax guides, data structures, algorithms, tutorials |
| **`AI`** | `Local-LLMs`, `Coding-Agents`, `Context-Engineering`, `Open-Source` | Ollama, token reduction, coding assistants, model guides |
| **`Research`** | `Open-Science`, `Bioinformatics` | Open-access papers, research methodologies, toolboxes |
| **`Career`** | `Job-Search`, `Pharmacy` | Interview prep, resume guides, industry career roadmaps |
| **`Health`** | `Nutrition`, `Mindfulness`, `Womens-Health` | Science-backed dietary guides, wellness |
| **`Buying-Guides`** | `Home-Appliances`, `Electric-Vehicles`, `Laptops` | Hardware and appliance evaluation frameworks |

---

## 5. On-Page Markdown SEO Best Practices

### 1. Heading Hierarchy (`MD025`, `MD001`)

- **Do NOT put `# H1 Title` in the markdown body.** Chirpy's post layout already renders the front matter `title:` as the single `<h1>` on the page.
- Begin the body directly with introduction text, followed by `## Section Title` (H2).
- Subsections must increment sequentially: `## H2` → `### H3` → `#### H4`. Never skip levels.

### 2. Internal Linking with `{% post_url %}`

- Always cross-link relevant guides to pass PageRank and reduce bounce rates.
- **Syntax:**
  ```markdown
  Check out our [macOS Developer Setup Guide]({% post_url 2022-03-23-macos-fresh-install-setup-guide %}){:target="_blank"}.
  ```
- **Caution:** Ensure the date in the tag strictly matches the target file's filename `YYYY-MM-DD-slug` to prevent Jekyll build failures.

### 3. Outbound Link Attributes

- Add `{:target="_blank" rel="noopener"}` to external links to prevent tab hijacking and protect user security:
  ```markdown
  Read the [Official Documentation](https://example.com){:target="_blank" rel="noopener"}.
  ```

### 4. Rich Snippet FAQ Schema (`FAQPage`)

For comprehensive guides and comparison articles, embed JSON-LD FAQ schema at the bottom of the post:

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the primary keyword question?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Direct, 2-3 sentence answer providing immediate value."
      }
    }
  ]
}
</script>
```

### 5. Chirpy Callout Prompts (Avoid Raw HTML)

Use Chirpy's native prompt callout blocks instead of raw `<div class="alert ...">` to keep markdown clean and pass linting:

```markdown
> This is a helpful tip or optimization note.
{: .prompt-tip }

> Important informational context for the reader.
{: .prompt-info }

> Warning about deprecation or common pitfall.
{: .prompt-warning }

> High-risk action that may cause data loss.
{: .prompt-danger }
```

---

## 6. Publishing Checklist

Before committing any new post to `_posts/`, run this verification:

```bash
# 1. Check front matter length
# Title <= 60 chars, Description between 130-155 chars

# 2. Check categories
# Must be exactly 2 items matching the Pillar hierarchy

# 3. Lint markdown formatting
npx markdownlint-cli2 "_posts/YOUR-NEW-POST.md"

# 4. Auto-fix table alignment and spacing if needed
npx markdownlint-cli2 --fix "_posts/YOUR-NEW-POST.md"

# 5. Verify clean Jekyll build
bundle exec jekyll build
```
