---
title: "Ultimate Markdown Cheatsheet: Complete Syntax Guide with Examples"
description: "Master Markdown syntax with this comprehensive cheatsheet. Includes text formatting, code blocks, tables, links, images, and advanced features."
author: sagarnikam123
date: 2015-06-27 12:00:00 +0530
categories: [programming, documentation]
tags: [markdown, cheatsheet, syntax, guide, reference]
math: true
---

Markdown is the most popular lightweight markup language used by developers, writers, and content creators worldwide. Created by <a href="https://daringfireball.net/projects/markdown/" target="_blank" rel="noopener">John Gruber</a>, this **ultimate markdown cheatsheet** provides complete syntax examples for text formatting, code blocks, tables, links, images, and advanced features. Whether you're writing documentation, README files, or blog posts, this comprehensive guide covers everything you need to master markdown syntax.

## Table of Contents

- [Text Formatting](#text-formatting)
- [Headers](#headers)
- [Lists](#lists)
- [Links](#links)
- [Images](#images)
- [Code](#code)
- [Tables](#tables)
- [Blockquotes](#blockquotes)
- [Horizontal Rules](#horizontal-rules)
- [Line Breaks](#line-breaks)
- [HTML Elements](#html-elements)
- [Media](#media)
- [Special Features](#special-features)
- [Math Expressions](#math-expressions)
- [Footnotes](#footnotes)
- [Comments](#comments)
- [Collapsible Sections](#collapsible-sections)
- [Anchor Links](#anchor-links)
- [Popular Markdown Editors](#popular-markdown-editors)
- [Markdown Flavors](#markdown-flavors)
- [Best Practices](#best-practices)
- [Conclusion](#conclusion)

## Text Formatting

### Emphasis

**Bold text**
```markdown
**Bold text** or __Bold text__
```

*Italic text*
```markdown
*Italic text* or _Italic text_
```

***Bold and italic***
```markdown
***Bold and italic*** or **_Bold and italic_**
```

~~Strikethrough~~
```markdown
~~Strikethrough~~
```

### Superscript and Subscript

Einstein's equation: E=mc<sup>2</sup> (superscript)
```
E=mc<sup>2</sup>
```

Water molecule: H<sub>2</sub>O (subscript)
```
H<sub>2</sub>O
```

### Escape Characters

Use backslash to escape special characters: \*literal asterisks\*
```markdown
\*literal asterisks\*
```

---

## Headers

### ATX Style (Recommended)

# H1 Header
## H2 Header
### H3 Header
#### H4 Header
##### H5 Header
###### H6 Header

```markdown
# H1 Header
## H2 Header
### H3 Header
#### H4 Header
##### H5 Header
###### H6 Header
```

### Setext Style (H1 and H2 only)

Header 1
========

Header 2
--------

```markdown
Header 1
========

Header 2
--------
```

*Note: Setext style only supports H1 (=) and H2 (-) headers. Use ATX style for H3-H6.*

---

## Lists

### Unordered Lists

* Item 1
* Item 2
  * Nested item
  * Another nested item
* Item 3

```markdown
* Item 1
* Item 2
  * Nested item
  * Another nested item
* Item 3
```

### Ordered Lists

1. First item
2. Second item
   1. Nested item
   2. Another nested item
3. Third item

```markdown
1. First item
2. Second item
   1. Nested item
   2. Another nested item
3. Third item
```

### Task Lists

- [x] Completed task
- [ ] Incomplete task
- [x] Another completed task

```markdown
- [x] Completed task
- [ ] Incomplete task
- [x] Another completed task
```

---

## Links

### Inline Links

This is a [Google](https://www.google.com "Google Homepage") link.
```markdown
[Google](https://www.google.com "Google Homepage")
```

### Reference Links

This is a [reference link][1] and another [reference link][google].

[1]: https://www.google.com "Google"
[google]: https://www.google.com

```markdown
[reference link][1]
[reference link][google]

[1]: https://www.google.com "Google"
[google]: https://www.google.com
```

### Automatic Links

https://www.google.com
```markdown
https://www.google.com
```

---

## Images

### Inline Images

![Markdown Logo](https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Markdown-mark.svg/150px-Markdown-mark.svg.png "Markdown Logo")
```markdown
![Markdown Logo](https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Markdown-mark.svg/150px-Markdown-mark.svg.png "Markdown Logo")
```

### Reference Images

![HTML5 Logo][html5-logo]

[html5-logo]: https://www.w3.org/html/logo/badge/html5-badge-h-solo.png "HTML5 Logo"

```markdown
![HTML5 Logo][html5-logo]

[html5-logo]: https://www.w3.org/html/logo/badge/html5-badge-h-solo.png "HTML5 Logo"
```

---

## Code

### Inline Code

Use `backticks` for inline code.
```markdown
Use `backticks` for inline code.
```

### Code Blocks

```
Plain code block
```

````markdown
```
Plain code block
```
````

### Syntax Highlighting

```javascript
function hello() {
    console.log("Hello World!");
}
```

````markdown
```javascript
function hello() {
    console.log("Hello World!");
}
```
````

### Indented Code Blocks

    This is an indented code block
    using 4 spaces or 1 tab

```markdown
    This is an indented code block
    using 4 spaces or 1 tab
```

### Line Numbers in Code Blocks

*Note: Line numbers syntax varies by platform. Some use `{linenos=true}`, others use different attributes.*

```javascript
function hello() {
    console.log("Hello World!");
    return true;
}
```

````markdown
```javascript {.line-numbers}
function hello() {
    console.log("Hello World!");
    return true;
}
```
````

---

## Tables

| Left Aligned | Center Aligned | Right Aligned |
|:-------------|:--------------:|--------------:|
| Left         | Center         | Right         |
| Text         | Text           | Text          |

```markdown
| Left Aligned | Center Aligned | Right Aligned |
|:-------------|:--------------:|--------------:|
| Left         | Center         | Right         |
| Text         | Text           | Text          |
```

### Simple Table

Column 1 | Column 2 | Column 3
---------|----------|----------
Data 1   | Data 2   | Data 3
Data 4   | Data 5   | Data 6

```markdown
Column 1 | Column 2 | Column 3
---------|----------|----------
Data 1   | Data 2   | Data 3
Data 4   | Data 5   | Data 6
```

---

## Blockquotes

> This is a blockquote.
>
> It can span multiple lines.
>
> > Nested blockquotes are also possible.

```markdown
> This is a blockquote.
>
> It can span multiple lines.
>
> > Nested blockquotes are also possible.
```

---

## Horizontal Rules

Three or more dashes, asterisks, or underscores:

---

***

___

```markdown
---
***
___
```

---

## Line Breaks

End a line with two or more spaces for a line break.

First line
Second line

```markdown
First line
Second line
```

---

## HTML Elements

### Definition Lists

<dl>
  <dt>Term 1</dt>
  <dd>Definition 1</dd>
  <dt>Term 2</dt>
  <dd>Definition 2</dd>
</dl>

```html
<dl>
  <dt>Term 1</dt>
  <dd>Definition 1</dd>
  <dt>Term 2</dt>
  <dd>Definition 2</dd>
</dl>
```

### Preformatted Text

<pre>
Preformatted text
preserves   spaces
and line breaks
</pre>

```html
<pre>
Preformatted text
preserves   spaces
and line breaks
</pre>
```

---

## Media

### YouTube Videos (HTML)

<a href="https://www.youtube.com/watch?v=mCG1tvUuCTo" target="_blank">
  <img src="https://img.youtube.com/vi/mCG1tvUuCTo/0.jpg" alt="Video Thumbnail" width="240" height="180">
</a>

```html
<a href="https://www.youtube.com/watch?v=mCG1tvUuCTo" target="_blank">
  <img src="https://img.youtube.com/vi/mCG1tvUuCTo/0.jpg" alt="Video Thumbnail" width="240" height="180">
</a>
```

### YouTube Videos (Markdown)

[![Video Thumbnail](https://img.youtube.com/vi/mCG1tvUuCTo/0.jpg)](https://www.youtube.com/watch?v=BZhWUE1A198)

```markdown
[![Video Thumbnail](https://img.youtube.com/vi/mCG1tvUuCTo/0.jpg)](https://www.youtube.com/watch?v=mCG1tvUuCTo)
```

---

## Special Features

### Emoji

😄 ❤️ 👍 🐙 (Unicode) or :smile: :heart: :thumbsup: :octocat: (shortcodes)

```markdown
😄 ❤️ 👍 🐙 (Unicode)
:smile: :heart: :thumbsup: :octocat: (shortcodes - requires jemoji plugin)
```

<a href="https://www.emoji-cheat-sheet.com/" target="_blank" rel="noopener">Emoji Cheatsheet</a>

### Highlighting

<mark>Highlighted text</mark>

```html
<mark>Highlighted text</mark>
```

### Keyboard Keys

Press <kbd>Ctrl</kbd> + <kbd>C</kbd> to copy.

```html
Press <kbd>Ctrl</kbd> + <kbd>C</kbd> to copy.
```

---

## Math Expressions

### Inline Math

This is inline math: $$ E = mc^2 $$ and here's another example with the quadratic formula $$ x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a} $$.

```markdown
$$ E = mc^2 $$
```

### Block Math

$$
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
$$

```markdown
$$
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
$$
```

### Equation Numbering

$$
\begin{equation}
E = mc^2 \label{eq:einstein}
\end{equation}
$$

You can reference the equation above using \eqref{eq:einstein}.

```markdown
$$
\begin{equation}
E = mc^2 \label{eq:einstein}
\end{equation}
$$

Reference with \eqref{eq:einstein}
```

### Math in Lists

1. First equation: \$$ a^2 + b^2 = c^2 $$
2. Second equation: \$$ \sum_{i=1}^{n} i = \frac{n(n+1)}{2} $$
3. Third equation: \$$ \lim_{x \to \infty} \frac{1}{x} = 0 $$

```markdown
1. \$$ a^2 + b^2 = c^2 $$
2. \$$ \sum_{i=1}^{n} i = \frac{n(n+1)}{2} $$
3. \$$ \lim_{x \to \infty} \frac{1}{x} = 0 $$
```

*Note: This site uses MathJax for rendering mathematical expressions. The Chirpy theme requires `math: true` in the front matter and specific syntax rules: use `$$ math $$` for inline math (no blank lines), `$$ math $$` with blank lines for block math, and escape the first `$` in lists with `\$$`.*

---

## Footnotes

This text has a footnote[^1].

[^1]: This is the footnote content.

```markdown
This text has a footnote[^1].

[^1]: This is the footnote content.
```

---

## Comments

<!-- This is a comment that won't be visible -->

```html
<!-- This is a comment that won't be visible -->
```

---

## Collapsible Sections

<details>
<summary>Click to expand</summary>

This content is hidden by default and can be expanded by clicking the summary.

- Item 1
- Item 2
- Item 3

Code example:

<pre><code>function example() {
    console.log("Hello from collapsible section!");
}
</code></pre>

</details>

```html
<details>
<summary>Click to expand</summary>

This content is hidden by default.

Code example:

<pre><code>function example() {
    console.log("Hello from collapsible section!");
}
</code></pre>

</details>
```

---

## Anchor Links

### Custom ID Headers {#custom-header}

[Link to custom header](#custom-header)

```markdown
### Custom ID Headers {#custom-header}
[Link to custom header](#custom-header)
```

---

## Popular Markdown Editors

Choose the right Markdown editor for your workflow:

### Online Editors
- **<a href="https://stackedit.io/" target="_blank" rel="noopener">StackEdit</a>** - Full-featured online editor with live preview, export to HTML/PDF, and cloud sync
- **<a href="https://dillinger.io/" target="_blank" rel="noopener">Dillinger</a>** - Clean web-based editor with export to HTML, styled HTML, PDF, and Markdown
- **<a href="https://hackmd.io/" target="_blank" rel="noopener">HackMD</a>** - Collaborative editor with real-time sync, presentation mode, and team features

### Desktop Applications
- **<a href="https://typora.io/" target="_blank" rel="noopener">Typora</a>** - WYSIWYG editor with seamless live preview and export capabilities
- **<a href="https://obsidian.md/" target="_blank" rel="noopener">Obsidian</a>** - Knowledge management with Markdown support and graph visualization

### IDE Extensions
- **<a href="https://github.com/preservim/vim-markdown" target="_blank" rel="noopener">Vim Markdown</a>** - Vim plugin for Markdown syntax highlighting and folding

---

## Markdown Flavors

Different platforms use variations of Markdown with additional features:

### <a href="https://commonmark.org/" target="_blank" rel="noopener">CommonMark</a>
Standardized specification for consistent Markdown parsing across platforms. Visit the <a href="https://spec.commonmark.org/" target="_blank" rel="noopener">CommonMark spec</a> for complete documentation.

### <a href="https://github.github.com/gfm/" target="_blank" rel="noopener">GitHub Flavored Markdown (GFM)</a>
Extends CommonMark with:
- Tables
- Task lists
- Strikethrough
- Autolinks
- Syntax highlighting in code blocks

### Extended Syntax
Many processors support additional features:
- Footnotes
- Definition lists
- Table alignment
- Abbreviations
- Math expressions (LaTeX)

*Note: Always check which Markdown flavor your target platform supports.*

## Best Practices

1. **Use consistent formatting** throughout your document
2. **Add blank lines** around headers and sections for readability
3. **Use descriptive alt text** for images
4. **Include titles** for links when helpful
5. **Test your markdown** in your target renderer
6. **Use reference links** for repeated URLs
7. **Indent nested lists** properly with 2-4 spaces
8. **Use semantic headers** (H1 for title, H2 for main sections)
9. **Keep line length reasonable** (80-120 characters)
10. **Preview before publishing** to catch formatting issues

## Conclusion

This comprehensive markdown cheatsheet covers all essential syntax from basic text formatting to advanced features like math expressions and collapsible sections. Bookmark this reference for quick lookup while writing documentation, README files, or blog posts. Remember to test your markdown in your target environment since different renderers may have slight variations in support.

For more comprehensive guides and tutorials, visit <a href="https://www.markdownguide.org/" target="_blank" rel="noopener">The Markdown Guide</a> - the definitive resource for learning Markdown.
