# SEO & Front Matter Guide for Jekyll Chirpy

This document defines the SEO standards, taxonomy rules, Core Web Vitals optimization, and front matter guidelines for **sagarnikam123.github.io** powered by the **Jekyll Chirpy** theme. Follow these principles whenever creating or updating posts and drafts.

---

## 1. Post File Naming & URL Structure

Jekyll Chirpy automatically generates canonical URL permalinks from the post filename:

- **Location:** `_posts/YYYY-MM-DD-title-slug.md` (or `_drafts/title-slug.md` during drafting).
- **Extension:** Must be `.md` or `.markdown`.
- **Format:** Lowercase words separated by hyphens (e.g., `2026-09-28-reduce-ai-token-usage-part1-techniques.md`).
- **URL Output:** Maps to `https://sagarnikam123.github.io/posts/title-slug/`.
- **Slug SEO:** Keep the slug concise (3–6 words) containing the primary target keyword. Avoid filler words (`and`, `the`, `of`) in filenames.

---

## 2. Anatomy of a Perfect Chirpy Front Matter

```yaml
---
title: "Primary Keyword First: Engaging Title Under 60 Characters"
description: "Actionable summary between 130 and 155 characters that naturally includes secondary search terms for search engine snippet preview."
author: sagarnikam123
date: 2026-09-28 09:30:00 +0530
last_modified_at: 2026-10-15 10:00:00 +0530   # Optional: set when substantially updating a published post
categories: [PrimaryPillar, SubCategory]
tags: [primary-keyword, secondary-search-term, specific-tool-name, relevant-concept]
media_subpath: /assets/img/posts/20260928/
image:
  path: descriptive-filename.webp
  lqip: data:image/webp;base64,...
  alt: Descriptive image alt text targeting image search SEO
pin: false        # Set true to pin post to the top of homepage (max 2-3)
toc: true         # Set true (default) to generate sticky right-rail table of contents
comments: true    # Set false to disable comments on this specific post
math: false       # Set true ONLY if post contains LaTeX math expressions ($$ / \begin{equation})
mermaid: false    # Set true ONLY if post contains mermaid code diagrams
---
```

> [!TIP]
> The post layout is set to `post` by default in Chirpy. There is no need to add `layout: post` in the front matter block.

---

## 3. Field-by-Field Chirpy SEO & Social Signals

### `title:` (Page Title & `<h1>`)

- **Length:** 50–60 characters (titles over 60 characters get truncated in Google SERPs).
- **Placement:** Front-load the primary search keyword within the first 3–5 words.
- **Rule:** Do **not** repeat the site name in `title:` — Chirpy and `jekyll-seo-tag` automatically append `| Sagar Nikam`.

### `description:` (Meta Description, RSS & Social Snippets)

- **Length:** **130–155 characters** (Strict ceiling: 160 characters).
- **Multi-surface Display:** In Chirpy, the `description` field feeds:
  1. `<meta name="description">` for Google search result snippets.
  2. `og:description` and `twitter:description` for social cards.
  3. The post summary displayed directly under the title on the post page.
  4. The summary preview on the homepage and "Further Reading" cards.
  5. The `<description>` tag in the RSS XML feed (`feed.xml`).
- **Content:** Include a direct answer, benefit statement, and a clear call-to-action.

### `author:` (E-E-A-T & Twitter Cards)

- Configure authors centrally in `_data/authors.yml`:
  ```yaml
  sagarnikam123:
    name: Sagar Nikam
    twitter: sagarnikam123
    url: https://sagarnikam123.github.io
  ```
- **SEO Benefit:** Reading author details from `_data/authors.yml` enables Chirpy to output `twitter:creator` and rich `author` schema, strengthening Google E-E-A-T (Experience, Expertise, Authoritativeness, Trustworthiness) verification.
- For multiple contributors, use `authors: [author1, author2]`.

### `date:` & `last_modified_at:` (Freshness & Structured Data Precision)

- **Format:** `YYYY-MM-DD HH:MM:SS +/-TTTT` (e.g., `2026-09-28 09:30:00 +0530`).
- **Why Timezone Matters:** Providing the exact timezone offset ensures accurate `datePublished` and `dateModified` in `BlogPosting` JSON-LD schema and prevents date skew in RSS feeds and search engine indexing.
- **Content Freshness (`last_modified_at:`):** When you substantially update an evergreen guide (e.g., adding new tools, updating archived projects, or refreshing benchmarks), set `last_modified_at:` in front matter. `jekyll-seo-tag` and `jekyll-sitemap` use it to emit an accurate `dateModified` and `<lastmod>` signal without changing the original `date:` permalink or publish history.

### `categories:` (Chirpy Two-Tier Hierarchy)

- **Strict Constraint:** Always use **exactly two levels**: `[PrimaryCategory, SubCategory]`.
  ```yaml
  # ✅ CORRECT:
  categories: [Observability, Logging]
  categories: [AI, Local-LLMs]
  categories: [Programming, Python]

  # ❌ INCORRECT (Breaks Chirpy UI accordion & creates thin archive traps):
  categories: [DevOps]                          # Only 1 level
  categories: [DevOps, Automation, Ansible]     # 3 levels (Chirpy only supports 2)
  categories: [devops, ansible]                 # lowercase (use PascalCase)
  ```
- **Archive Authority:** Chirpy's `_layouts/categories.html` renders an accordion with a parent and child tier. Maintaining two tiers prevents empty category traps and groups topical authority.

### `tags:` (Search Intent & Keyword Clustering)

- **Quantity:** 4–6 targeted keywords per post.
- **Format:** Lowercase `kebab-case` only (e.g., `context-engineering`, `llm-token-reduction`).
- **Never use `keywords:`:**
  > [!IMPORTANT]
  > Neither `jekyll-seo-tag` nor search engines recognize a `keywords:` frontmatter key. Always use Chirpy's native `tags:` array.

### `media_subpath:` & `site.cdn` (Asset Path Simplification)

- Sets a default directory prefix for media resources in the post:
  ```yaml
  media_subpath: /assets/img/posts/20260928/
  ```
- When `media_subpath` is configured, `image.path` and standard markdown images only require the filename (e.g., `reduce-token-usage.webp`). Chirpy composes the final URL as `[site.cdn/][page.media_subpath/]file.ext`, keeping markdown clean and portable across CDNs.

### Performance Toggles (`math:`, `mermaid:`, `toc:`)

- Keep `math: false` and `mermaid: false` by default. Only set to `true` when equations or diagrams are present. Loading unused MathJax or Mermaid JS scripts increases page weight and hurts Core Web Vitals (INP/LCP).

---

## 4. Core Web Vitals & Image SEO Standards

Images are the primary contributor to Largest Contentful Paint (LCP) and Cumulative Layout Shift (CLS). Chirpy provides built-in mechanisms to optimize them:

### 1. Preview Image (Hero / Social Card)

- **Target Resolution:** **1200 x 630 px** (standard 1.91:1 aspect ratio for Open Graph, Facebook, LinkedIn, and Twitter `summary_large_image`).
- **Format:** Modern `.webp` format for high compression and fast delivery.
- **LQIP (Low Quality Image Placeholder):** Provide a tiny base64 URI or file path to render instantly while the full image loads (for both hero preview images and inline content images):
  ```yaml
  image:
    path: hero-image.webp
    lqip: data:image/webp;base64,UklGRm... # or /path/to/lqip-file
    alt: Descriptive keyword-rich image explanation
  ```
  ```markdown
  ![Inline Diagram](diagram.webp){: w="800" h="450" lqip="/path/to/lqip-file" }
  ```

### 2. In-Content Image Dimensions (Prevent CLS)

To prevent page layout shifts while images load, specify explicit dimensions using Chirpy's attribute syntax:

```markdown
<!-- Standard attribute syntax -->
![Architecture Diagram](architecture.webp){: width="800" height="450" }

<!-- Chirpy shorthand syntax (v5.0+) -->
![Architecture Diagram](architecture.webp){: w="800" h="450" }
```

> [!NOTE]
> For SVG images, at least the `width` or `w` attribute must be specified for Chirpy to render it properly.

### 3. Captions & Image Alignment

- **Captions:** Place italicized text on the immediate line below the image:
  ```markdown
  ![OpenTelemetry Collector Pipeline](otel-pipeline.webp){: w="750" h="400" }
  _Figure 1: High-throughput log aggregation pipeline with OpenTelemetry Collector._
  ```
- **Alignment Classes:**
  - `{: .normal }` — Left aligned.
  - `{: .left }` — Floated to the left with text wrap.
  - `{: .right }` — Floated to the right with text wrap.
  - `{: .shadow }` — Adds modern drop-shadow (ideal for software UI screenshots).
  > [!WARNING]
  > When alignment classes (`.normal`, `.left`, `.right`) are applied, do not add captions below the image.

### 4. Theme-Aware Images (Dark / Light Mode)

For screenshots or diagrams that differ between dark and light themes:

```markdown
![System Dashboard Light](dashboard-light.webp){: .light }
![System Dashboard Dark](dashboard-dark.webp){: .dark }
```

---

## 5. Responsive Media Embeds (Performance-Safe)

Embedding raw `<iframe>` tags from YouTube, Twitch, Bilibili, or Spotify degrades PageSpeed scores and triggers CLS. Use Chirpy's native responsive Liquid includes instead (`{% include embed/{Platform}.html id='{ID}' %}`):

```liquid
{% comment %} YouTube / Twitch / Bilibili Video {% endcomment %}
{% include embed/youtube.html id='VIDEO_ID' %}
{% include embed/twitch.html id='VIDEO_ID' %}
{% include embed/bilibili.html id='VIDEO_ID' %}

{% comment %} Spotify Podcast or Track {% endcomment %}
{% include embed/spotify.html id='TRACK_ID' compact=1 dark=1 %}

{% comment %} Self-Hosted Video File with Poster {% endcomment %}
{% include embed/video.html
  src='/assets/video/demo.mp4'
  poster='/assets/img/demo-poster.webp'
  title='Feature Demonstration'
  types='ogg|mov'
%}

{% comment %} Self-Hosted Audio File {% endcomment %}
{% include embed/audio.html
  src='/assets/audio/podcast.mp3'
  title='Episode Audio'
  types='ogg|wav'
%}
```

---

## 6. Approved Category Taxonomy (The Core Pillars)

To avoid "thin content" penalties where search engines index categories containing only 1 or 2 posts, strictly adhere to this pre-established pillar hierarchy:

| Primary Pillar (Level 1) | Approved Sub-Categories (Level 2) | Topic Scope |
| --- | --- | --- |
| **`Observability`** | `Platforms`, `Logging`, `Metrics`, `Tracing`, `Profiling`, `Benchmarks`, `Pricing`, `APM`, `Security`, `Landscape` | Monitoring, Grafana, OpenTelemetry, SigNoz, Vector, Loki |
| **`DevOps`** | `Ansible`, `Kafka`, `Testing`, `Setup`, `Automation`, `CI-CD`, `Streaming`, `Containers`, `Kubernetes` | Infrastructure as code, containers, local Kubernetes, pipelines, Playwright, message brokers, stream/batch data platforms |
| **`Linux`** | `Commands`, `Troubleshooting`, `Setup`, `Administration` | CLI workflows, sysadmin one-liners, kernel tuning, distros |
| **`Programming`** | `Go`, `Python`, `R`, `C-Cpp`, `Git`, `Markdown`, `Coding-Challenges`, `Web-Development` | Syntax guides, data structures, algorithms, tutorials |
| **`AI`** | `Local-LLMs`, `Coding-Agents`, `Context-Engineering`, `Open-Source` | Ollama, token reduction, coding assistants, model guides |
| **`Research`** | `Open-Science`, `Bioinformatics` | Open-access papers, research methodologies, toolboxes |
| **`Career`** | `Job-Search`, `Pharmacy` | Interview prep, resume guides, industry career roadmaps |
| **`Health`** | `Nutrition`, `Mindfulness`, `Womens-Health` | Science-backed dietary guides, wellness |
| **`Buying-Guides`** | `Home-Appliances`, `Electric-Vehicles`, `Laptops` | Hardware and appliance evaluation frameworks |

---

## 7. On-Page Markdown & Typography Standards

### 1. Heading Hierarchy (`MD025`, `MD001`)

- **Do NOT put `# H1 Title` in the markdown body.** Chirpy's post layout renders the front matter `title:` as the single `<h1>` on the page.
- Begin the body directly with introduction text, followed by `## Section Title` (H2).
- Subsections must increment sequentially: `## H2` → `### H3` → `#### H4`. Never skip levels.

### 2. Chirpy Callout Prompts (Lint-Clean)

Use Chirpy's native prompt callout blocks instead of raw HTML:

```markdown
> Actionable tip or optimization guideline.
{: .prompt-tip }

> Helpful informational context for the reader.
{: .prompt-info }

> Warning about deprecation, cost impact, or common pitfalls.
{: .prompt-warning }

> High-risk action that may cause data loss or service disruption.
{: .prompt-danger }
```

### 3. Code Blocks & Filepath Badges

- **Language Highlight:** Always tag code fences (````yaml````, ````python````, ````bash````).
  > [!CAUTION]
  > Jekyll's `{% highlight %}` tag is incompatible with Chirpy. Always use standard markdown fences.
- **Filename Header:** Add `{: file="path/to/file.ext" }` below the code block.
- **Hide Line Numbers:** `plaintext`, `console`, and `terminal` omit line numbers automatically; for other languages, add `{: .nolineno }` below the code block.
- **Inline Filepaths:** Use `` `/etc/nginx/nginx.conf`{: .filepath} `` to render Chirpy's distinct filepath badge.
- **Liquid Code Snippets:** Surround Liquid tags with `{% raw %}` and `{% endraw %}` or set `render_with_liquid: false` in front matter.

### 4. Internal & External Linking (Topic Clusters & Anchor Text)

- **Internal Links:** Use `{% post_url YYYY-MM-DD-slug %}` to maintain permanent links even if slugs change (open in the same tab — no `target="_blank"`):
  ```markdown
  Refer to our [Token Usage Optimization Guide]({% post_url 2026-09-28-reduce-ai-token-usage-part1-techniques %}).
  ```
- **Descriptive Anchor Text:** Use keyword-relevant, descriptive anchor text (e.g., *"Open-Source Container Runtimes Compared"* rather than *"here"* or *"this post"*).
- **Topic Clusters & Anti-Cannibalization:** Group related posts into complementary series (e.g., *Layer 1: Container Runtimes* ↔ *Layer 2: Local Kubernetes Installers*) with clear scope boundaries and bidirectional links so two posts reinforce each other instead of competing for the same query.
- **No Draft Links in Published Posts:** Always replace `/_drafts/...` links with `{% post_url %}` before moving a post into `_posts/`.
- **External Links:** Standard Markdown `[label](https://...)` is clean and preferred; optionally add Kramdown IAL syntax `{:target="_blank" rel="noopener"}` when you want external links to open in a new tab (Jekyll strips the `{:...}` syntax during build and emits HTML `target="_blank" rel="noopener"` attributes). Cite primary official docs and GitHub repos to strengthen E-E-A-T.

### 5. Featured Snippet, AI Overview (AEO/GEO) & E-E-A-T Optimization

To capture Google's definition snippets and AI Overview citations:

- Directly under an H2 question or concept heading (`## What is X?`), write a concise, self-contained definition of **40–50 words**.
- Bold the primary keyword in the first sentence (e.g., *"**AI token optimization** is the discipline of minimizing input and output token consumption..."*).
- Follow immediately with a summary list or comparison table to qualify for tabular and bulleted snippet formats.
- **Demonstrate First-Hand E-E-A-T:** Include reproducible CLI commands, explicit trade-offs (*"When to prefer / When not"*), maintenance-status caveats (archived/beta tools), and real gotchas rather than generic feature summaries.

---

## 8. Structured Data (JSON-LD) Strategy

### Native Chirpy Schema (`jekyll-seo-tag`)

Chirpy automatically includes `{% seo title=false %}` in `_includes/head.html`, which natively generates complete, valid JSON-LD structured data in the `<head>` of every post:

- `@context: "https://schema.org"`
- `@type: "BlogPosting"`
- `headline`, `description`, `author`, `datePublished`, `dateModified`, `mainEntityOfPage`
- Canonical URL, Open Graph, and Twitter Card metadata.

### Strict Markdown Purity: No Embedded Script Tags

- **Rule:** Do **not** embed manual `<script type="application/ld+json">` tags inside markdown post bodies.
- **Why?**
  1. **Redundancy:** Chirpy already generates standards-compliant `BlogPosting` schema on every page.
  2. **Clean Markdown:** Keeping markdown files 100% free of inline `<script>` tags preserves clean syntax, prevents markdownlint `MD033` issues, and avoids accidental script parsing errors in Jekyll.
  3. **Google Guidelines:** Google automatically derives question-and-answer snippets from standard semantic markdown headings (`## Frequently Asked Questions`, followed by `###` question headings or bold questions and concise answers) without requiring manual schema injection.

---

## 9. Favicons, Brand Identity & SERP Snippet SEO

Google Search on both mobile and desktop displays the website's favicon directly next to the URL and title in search results. A crisp, high-resolution favicon increases click-through rates (CTR) and reinforces brand recognition.

### Required Favicon Assets (`assets/img/favicons/`)

Chirpy's `<head>` configuration requires:

- `favicon.ico` — Classic multi-resolution icon.
- `favicon.svg` — Scalable vector icon for modern high-DPI displays.
- `favicon-96x96.png` — High-resolution desktop browser tab and SERP icon.
- `apple-touch-icon.png` (180x180) — iOS home screen bookmark icon.
- `site.webmanifest` — Web App Manifest specifying icons (192x192, 512x512) and theme colors.

### Generation Workflow

1. Prepare a square master image (PNG or SVG) of at least **512 x 512 px**.
2. Generate the package using [RealFaviconGenerator](https://realfavicongenerator.net/).
3. Delete the downloaded `site.webmanifest` from the generator to preserve Chirpy's customized `site.webmanifest`.
4. Copy the `.png`, `.ico`, and `.svg` files into `assets/img/favicons/`.

---

## 10. Technical SEO Configuration & Production Build

### Configuration Anchors (`_config.yml`)

Ensure these values are accurately set:

- `url`: Must be the absolute production domain (`https://sagarnikam123.github.io`) without trailing slashes.
- `baseurl`: Must be empty `""` for user sites (`<username>.github.io`) or `"/project-name"` for project sites.
- `timezone`: Controls site-wide post timestamp rendering.
- `lang`: Sets the `<html lang="en">` attribute required for international search indexing.

- **Production Build & Lockfile:** If `Gemfile.lock` is committed on macOS/Windows, add the Linux platform before GitHub Actions deployment (`bundle lock --add-platform x86_64-linux`).
- **Static Assets & CDN:** Chirpy's external asset CDNs are configured in `_data/origin/cors.yml` (or can be self-hosted via `chirpy-static-assets`).

### Production Build Flag

Always build with `JEKYLL_ENV=production`:

```bash
JEKYLL_ENV=production bundle exec jekyll b
```

> [!IMPORTANT]
> Chirpy disables Google Analytics, GoatCounter tracking, pageview counts, and certain canonical SEO optimizations in development mode. Only production builds emit the complete, minified SEO assets.

### Automated Sitemap, Canonical URLs & Robots Discovery

- **XML Sitemap:** Chirpy automatically generates a search-engine-ready XML sitemap at `/sitemap.xml` using `jekyll-sitemap`. Ensure `url` is configured in `_config.yml` so all links use full canonical URLs.
- **Canonical & Cross-Posting:** `jekyll-seo-tag` emits `<link rel="canonical">` automatically. When syndicating posts to Medium, Dev.to, or Hashnode, always set the syndication platform's canonical URL back to your `https://sagarnikam123.github.io/posts/<slug>/` URL to prevent duplicate-content dilution.
- **Robots.txt:** Keep a valid `robots.txt` in the root referencing the sitemap:
  ```text
  Sitemap: https://sagarnikam123.github.io/sitemap.xml
  ```

---

## 11. Pre-Publishing Checklist

Before committing any post or merging drafts into `_posts/`:

```bash
# 1. Verify front matter SEO constraints
# - Title <= 60 chars (primary keyword first)
# - Description between 130-155 chars
# - Categories: exactly 2 items matching Core Pillars
# - Tags: 4-6 lowercase kebab-case terms
# - Image: 1200x630 webp with valid LQIP base64 and alt text
# - Freshness: set last_modified_at if substantially updating an existing post
# - Links: no /_drafts/ links remaining; use {% post_url %} for internal links

# 2. Lint markdown syntax and heading order
npx markdownlint-cli2 "_posts/YYYY-MM-DD-your-post.md"

# 3. Auto-fix formatting if issues detected
npx markdownlint-cli2 --fix "_posts/YYYY-MM-DD-your-post.md"

# 4. Verify clean Jekyll production build
JEKYLL_ENV=production bundle exec jekyll build
```
