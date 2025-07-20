---
layout: post
title: "Markdown Syntax (Cheatsheet)"
date: 2015-06-27
description: how to use markdown syntax with example codes
output: html_document
tags: [learn, markdown, cheatsheet]
category: [tips & tricks, programming]
---

## Emphasis

*Italics*

`*Italics*` or `_Italics_`

**Bold**

`**Bold**` or `__Bold__`

**_Bold & Italics_**

```
**_Bold & Italics_**
```

---

## Headers
---
> #### Setext-style:(underline)

Header 1
========

Header 2
--------

	Header 1
	========
	Header 2
	--------

---

> #### using hashtags

# H1

## H2

### H3

#### H4

##### H5

###### H6

	# H1
	## H2
	### H3
	#### H4
	##### H5
	###### H6

---

## Lists

> #### Ordered (without paragraphs)

1.  One
2.  Two


	    1.  One
		2.  Two

---

> #### Unordered (with paragraphs)

* A lst item.
With multiple paragraphs.
Second line.
* Bar


		* A lst item.
		With multiple paragraphs.
		Second line.
		* Bar

---

> #### Nested List

Use chars like plus `+`, minus `-`, asterik `*` & roman digits `iv`.

* Abacus
  * asterik
  - minus
  + plus
* Bubbles
  1.  bunk
  2.  bupkis
      * BELITTLER
  3. burper
* Cunning
  i. Roman value.
  ii. Second value.


		* Abacus
		  * asterik
		  - minus
		  + plus
		* Bubbles
		  1.  bunk
		  2.  bupkis
			  * BELITTLER
		  3. burper
		* Cunning
		  i. Roman value.
		  ii. Second value.

---

## Manual Line Breaks
End a line with **two or more spaces**.

Roses are red,
Violets are blue.

	Roses are red,
	Violets are blue.

---

## Link

> #### Inline

This is a [Google](https://www.google.co.in/ "Google-India") inline link. Hover mouse to view text.

[I'm a relative reference to a repository file](../blob/master/LICENSE)

	This is a [Google](https://www.google.co.in/ "Google-India") inline link.
	[I'm a relative reference to a repository file](../blob/master/LICENSE)

---

> #### Autolinking URL (in GitHub's markdown)

http://daringfireball.net

	http://daringfireball.net

---

> #### Reference-style labels (titles are optional)

A [Google][1] Link. Then, anywhere
else in the doc/bottom of doc, define the link.

A [Yahoo][2] Link. Look at below reference ids for their association.

Or leave it empty and use direct [Wikipedia]

[1]: https://www.google.co.in/ "Google India"
[2]: https://in.yahoo.com/ "Yahoo India"
[Wikipedia]: http://en.wikipedia.org/wiki/Main_Page


	A [Google][1] Link. Then, anywhere
	else in the doc/bottom of doc, define the link.

	A [Yahoo][2] Link. Look at below reference ids for their association.

	Or leave it empty and use direct [Wikipedia]

	  [1]: https://www.google.co.in/ "Google India"
	  [2]: https://in.yahoo.com/ "Yahoo India"
	  [Wikipedia]: http://en.wikipedia.org/wiki/Main_Page

---

## Blockquotes

> Email-style angle brackets
> are used for blockquotes.

> > And, they can be nested.

> > ##### Headers in blockquotes
>
> * You can quote a list.
> * Etc.

	> Email-style angle brackets
	> are used for blockquotes.

	> > And, they can be nested.

	> > ##### Headers in blockquotes
	>
	> * You can quote a list.
	> * Etc.

---

## Code

> #### Inline code

`<code>` This is inline code, use backticks.

	`<code>` This is inline code, use backticks.

---

> #### Plain Code Blocks

```
System.out.println("Hello World !");
```

	```System.out.println("Hello World !");
	```

---

> #### Code Blocks (using spaces/tabs)

* Indent every line of a code block by at least **4 spaces** or __1 tab__.

	This is a preformatted
	code block.

```
	This is a preformatted
	code block.
```

---

> #### Code block with Syntax highlighting

* add type of language after backticks

```javascript
var s = "JavaScript syntax highlighting";
alert(s);
```

    ```javascript
    var s = "JavaScript syntax highlighting";
    alert(s);
	```

---

> #### Pre-Formatted (monospace) text

<pre>Use pre tags to format a paragraph or sentence as monospaced text.</pre>

	<pre>Use pre tags to format a paragraph or sentence as monospaced text.</pre>

---

## Images

> #### Inline (titles are optional)

![alternative text if image not rendered](/path/img.jpg "Image Title")


	![alternative text if image not rendered](/path/img.jpg "Image Title")

---

> #### Reference-style

![alternative text 4 Google logo](1)
![Wikipedia](2)

[1]: https://www.google.co.in/images/srpr/logo11w.png "Google Logo"
[2]: http://upload.wikimedia.org/wikipedia/commons/8/80/Wikipedia-logo-v2.svg "Wikipedia logo"


	![alternative text 4 Google logo](1)
	![Wikipedia](2)

	[1]: https://www.google.co.in/images/srpr/logo11w.png "Google Logo"
	[2]: http://upload.wikimedia.org/wikipedia/commons/8/80/Wikipedia-logo-v2.svg "Wikipedia logo"

-----

## Lines (Horizontal Rules/Page Break)

**Three** or more **dashes** or _asterisks_:

---
* * *
- - - -


	---
	* * *
	- - - -

---

## Tables

* Use colon **`:`** within the header row.
* You can define text to be left-aligned, right-aligned or center-aligned.

---

| Left-Aligned  | Center Aligned  | Right Aligned |
| :------------ |:---------------:| -----:|
| col 3 is      | some wordy text | $1600 |
| col 2 is      | centered        |   $12 |
| zebra stripes | are neat        |    $1 |

---

<pre>
| Left-Aligned  | Center Aligned  | Right Aligned |
| :------------ |:---------------:| -----:|
| col 3 is      | some wordy text | $1600 |
| col 2 is      | centered        |   $12 |
| zebra stripes | are neat        |    $1 |
</pre>

---

* Outer pipes [ **\|** ] are optional
* dashes at the top don't need to match the length of the header text exactly.

---

Markdown | Less      | Pretty
-------- | --------- | ----------
*Still*  | `renders` | **nicely**
1        | 2         | 3

---

<pre>
Markdown | Less      | Pretty
-------- | --------- | ----------
*Still*  | `renders` | **nicely**
1        | 2         | 3
</pre>

-----


## Inline HTML

* can use raw HTML directly.

<dl>
  <dt>Definition list</dt>
  <dd>Is something people use sometimes.</dd>

  <dt>Markdown in HTML</dt>
  <dd>Does *not* work **very** well. Use HTML <em>tags</em>.</dd>
</dl>

	<dl>
	  <dt>Definition list</dt>
	  <dd>Is something people use sometimes.</dd>

	  <dt>Markdown in HTML</dt>
	  <dd>Does *not* work **very** well. Use HTML <em>tags</em>.</dd>
	</dl>

---

## Videos

* Supports **Youtube** & **Dailymotion** videos (Others are supported if direct URL to to video, ending with .mp4 .3gp etc.)
* can't be added directly but you can add an image with a link to the video as


<a href="http://www.youtube.com/watch?feature=player_embedded&v=YOUTUBE_VIDEO_ID_HERE
" target="_blank"><img src="http://img.youtube.com/vi/YOUTUBE_VIDEO_ID_HERE/0.jpg"
alt="IMAGE ALT TEXT HERE" width="240" height="180" border="10" /></a>

	<a href="http://www.youtube.com/watch?feature=player_embedded&v=YOUTUBE_VIDEO_ID_HERE
	" target="_blank"><img src="http://img.youtube.com/vi/YOUTUBE_VIDEO_ID_HERE/0.jpg"
	alt="IMAGE ALT TEXT HERE" width="240" height="180" border="10" /></a>

---

Or, in pure Markdown, but losing the image sizing and border:
* replace ` BZhWUE1A198 ` with your uTube video id.
* You can use ` 0.jpg / 1.jpg / 2.jpg / 3.jpg / 4.jpg. `

[![IMAGE ALT TEXT HERE](http://img.youtube.com/vi/BZhWUE1A198/1.jpg)](http://www.youtube.com/watch?v=YOUTUBE_VIDEO_ID_HERE)

	[![IMAGE ALT TEXT HERE](http://img.youtube.com/vi/BZhWUE1A198/1.jpg)](http://www.youtube.com/watch?v=YOUTUBE_VIDEO_ID_HERE)

---

> Linking specific section of video

* E.g. starting at 120sec(2.00 min) & end to 240 sec(4.00 min).

[![IMAGE ALT TEXT HERE](http://img.youtube.com/vi/BZhWUE1A198/1.jpg)](http://www.youtube.com/watch?v=BZhWUE1A198?start=120&end=240)

	[![IMAGE ALT TEXT HERE](http://img.youtube.com/vi/BZhWUE1A198/1.jpg)](http://www.youtube.com/watch?v=YOUTUBE_VIDEO_ID_HERE?start=120&end=240)

---

## Miscellaneous

> #### Suprescript

E=mc<sup>2</sup>

	E=mc<sup>2</sup>

---

> #### Subscript

H<sub>2</sub>O

	H<sub>2</sub>O

---

> #### Scratch/Strikethrough

~~Scratch this.~~

or

~~strikethrough~~

<pre>
~~Scratch this.~~
or
~~strikethrough~~
</pre>

---

> #### Escape Characters

M\*A\*S\*H

	M\*A\*S\*H

---

> #### Emoji

[Emoji cheatsheet](http://www.emoji-cheat-sheet.com/ "Emoji Cheatsheet")

:joy:  :heart_eyes:  :stuck_out_tongue_winking_eye:  :octocat:

	:joy:  :heart_eyes: :stuck_out_tongue_winking_eye:  :octocat:

---

> #### Font colors

<span data-highlight-class="X">TEXT</span>

	<span data-highlight-class="X">TEXT</span>

* replace 'X' with letter below

<pre>
hll
c
g
k
gr
kt
m
na
no
nv
</pre>

---

> #### Checkbox

- [x] A
- [ ] B
- [x] C

```
- [x] A
- [ ] B
- [x] C
```

---

```

```

> #### TASK LISTS

- [x] this is a complete item
- [ ] this is an incomplete item
- [x] @mentions, #refs, [links](),
**formatting**, and <del>tags</del>
supported
- [x] list syntax required (any
unordered or ordered list
supported)


```
- [x] this is a complete item
- [ ] this is an incomplete item
- [x] @mentions, #refs, [links](),
**formatting**, and <del>tags</del>
supported
- [x] list syntax required (any
unordered or ordered list
supported)
```
