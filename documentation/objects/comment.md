---
layout: default
title: comment

nav:
  group: Liquid Variables
---

# comment

The <code>comment</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}


{% anchor_link "comment.id", "comment-id" %}

Returns the id (unique identifier) of the comment.





{% anchor_link "comment.author", "comment-author" %}

Returns the author of the comment. 






{% anchor_link "comment.email", "comment-email" %}

Returns the e-mail address of the comment's author.





{% anchor_link "comment.content", "comment-content" %}

Returns the content of the comment.






{% anchor_link "comment.status", "comment-status" %}

Returns the status of the comment. The possible values are: 

- unapproved
- published
- removed
- spam






{% anchor_link "comment.url", "comment-url" %}

Returns the URL of the article with <code>comment.id</code> appended to it.  This is so the page will automatically scroll to the comment.




