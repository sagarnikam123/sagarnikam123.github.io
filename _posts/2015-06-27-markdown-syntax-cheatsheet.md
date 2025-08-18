---
title: "Complete Markdown Syntax Cheatsheet with Examples"
description: "Complete markdown syntax guide with examples covering text formatting, headers, lists, code blocks, tables, links, images, footnotes, and advanced features for developers and writers."
date: 2015-06-27 12:00:00 +0530
categories: [programming]
tags: [markdown, cheatsheet, learn]
---

## Text Formatting

### Emphasis

**Bold text**
```
**Bold text** or __Bold text__
```

*Italic text*
```
*Italic text* or _Italic text_
```

***Bold and italic***
```
***Bold and italic*** or **_Bold and italic_**
```

~~Strikethrough~~
```
~~Strikethrough~~
```

### Superscript and Subscript

E=mc<sup>2</sup>
```
E=mc<sup>2</sup>
```

H<sub>2</sub>O
```
H<sub>2</sub>O
```

### Escape Characters

Use backslash to escape special characters: \*literal asterisks\*
```
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

```
# H1 Header
## H2 Header
### H3 Header
#### H4 Header
##### H5 Header
###### H6 Header
```

### Setext Style

Header 1
========

Header 2
--------

```
Header 1
========

Header 2
--------
```

---

## Lists

### Unordered Lists

* Item 1
* Item 2
  * Nested item
  * Another nested item
* Item 3

```
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

```
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

```
- [x] Completed task
- [ ] Incomplete task
- [x] Another completed task
```

---

## Links

### Inline Links

This is a [Google](https://www.google.com "Google Homepage") link.
```
[Google](https://www.google.com "Google Homepage")
```

### Reference Links

This is a [reference link][1] and another [reference link][google].

[1]: https://www.google.com "Google"
[google]: https://www.google.com

```
[reference link][1]
[reference link][google]

[1]: https://www.google.com "Google"
[google]: https://www.google.com
```

### Automatic Links

https://www.google.com
```
https://www.google.com
```

---

## Images

### Inline Images

![Alt text](https://via.placeholder.com/150 "Image title")
```
![Alt text](https://via.placeholder.com/150 "Image title")
```

### Reference Images

![Google Logo][logo]

[logo]: https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png "Google Logo"

```
![Google Logo][logo]

[logo]: https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png
```

---

## Code

### Inline Code

Use `backticks` for inline code.
```
Use `backticks` for inline code.
```

### Code Blocks

```
Plain code block
```

````
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

````
```javascript
function hello() {
    console.log("Hello World!");
}
```
````

### Indented Code Blocks

    This is an indented code block
    using 4 spaces or 1 tab

```
    This is an indented code block
    using 4 spaces or 1 tab
```

### Line Numbers in Code Blocks

```javascript {linenos=true}
function hello() {
    console.log("Hello World!");
    return true;
}
```

````
```javascript {linenos=true}
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

```
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

```
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

```
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

```
---
***
___
```

---

## Line Breaks

End a line with two or more spaces for a line break.

First line  
Second line

```
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

<a href="https://www.youtube.com/watch?v=BZhWUE1A198" target="_blank">
  <img src="https://img.youtube.com/vi/BZhWUE1A198/0.jpg" alt="Video Thumbnail" width="240" height="180">
</a>

```html
<a href="https://www.youtube.com/watch?v=BZhWUE1A198" target="_blank">
  <img src="https://img.youtube.com/vi/BZhWUE1A198/0.jpg" alt="Video Thumbnail" width="240" height="180">
</a>
```

### YouTube Videos (Markdown)

[![Video Thumbnail](https://img.youtube.com/vi/BZhWUE1A198/0.jpg)](https://www.youtube.com/watch?v=BZhWUE1A198)

```
[![Video Thumbnail](https://img.youtube.com/vi/BZhWUE1A198/0.jpg)](https://www.youtube.com/watch?v=BZhWUE1A198)
```

---

## Special Features

### Emoji

😄 ❤️ 👍 🐙 (Unicode) or :smile: :heart: :thumbsup: :octocat: (shortcodes)

```
😄 ❤️ 👍 🐙 (Unicode)
:smile: :heart: :thumbsup: :octocat: (shortcodes - requires jemoji plugin)
```

<a href="https://www.emoji-cheat-sheet.com/" target="_blank">Emoji Cheatsheet</a>

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

This is inline math: $E = mc^2$

```
$E = mc^2$
```

### Block Math

$$
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
$$

```
$$
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
$$
```

*Note: Requires MathJax or KaTeX support*

---

## Footnotes

This text has a footnote[^1].

[^1]: This is the footnote content.

```
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

</details>

```html
<details>
<summary>Click to expand</summary>

This content is hidden by default.

</details>
```

---

## Anchor Links

### Custom ID Headers {#custom-header}

[Link to custom header](#custom-header)

```
### Custom ID Headers {#custom-header}
[Link to custom header](#custom-header)
```

---

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
