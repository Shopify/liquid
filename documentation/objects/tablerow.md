---
layout: default
title: tablerow

nav:
  group: Liquid Variables
---

# tablerow

The <code>tablerow</code> object is used within the <a href="/themes/liquid-documentation/tags/iteration-tags/#tablerow">tablerow</a> tag. It contains attributes of its parent for loop. 

<a id="topofpage"></a>
{% table_of_contents %}




{% anchor_link " tablerow.length", "tablerow-length" %}

<p>Returns the number of iterations of the <tt>tablerow</tt> loop.</p>










{% anchor_link " tablerow.index", "tablerow-index" %}

Returns the current index of the <tt>tablerow</tt> loop, starting at 1. 








{% anchor_link " tablerow.index0", "tablerow-index0" %}

Returns the current index of the <tt>tablerow</tt> loop, starting at 0. 








{% anchor_link " tablerow.rindex", "tablerow-rindex" %}

Returns <a href="#tablerow.index">tablerow.index</a> in reverse order.








{% anchor_link " tablerow.rindex0", "tablerow-rindex0" %}

Returns <a href="#tablerow.index0">tablerow.index0</a> in reverse order.








{% anchor_link " tablerow.first", "tablerow-first" %}

Returns <code>true</code> if it's the first iteration of the <tt>tablerow</tt> loop. Returns <code>false</code> if it is not the first iteration. 









{% anchor_link  "tablerow.last", "tablerow-last" %}

Returns <code>true</code> if it's the last iteration of the <tt>tablerow</tt> loop. Returns <code>false</code> if it is not the last iteration. 









{% anchor_link "tablerow.col", "tablerow-col" %}

Returns the index of the current row, starting at 1.








{% anchor_link "tablerow.col0", "tablerow-col0" %}

Returns the index of the current row, starting at 0.









{% anchor_link "tablerow.col_first", "tablerow-col_first" %}

Returns <code>true</code> if the current column is the first column in a row, returns <code>false</code> if it is not. 









{% anchor_link " tablerow.col_last", "tablerow-col_last" %}

Returns <code>true</code> if the current column is the last column in a row, returns <code>false</code> if it is not. 



