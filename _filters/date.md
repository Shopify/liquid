---
title: date
---

`date` converts a timestamp into another date format.

| Input                                                                     | Output               |
|--------------------------------------------------------------------------:|:---------------------|
| {% raw %}`{{ article.published_at | date: "%a, %b %d, %y" }}`{% endraw %} | Tue, Apr 22, 14      |
| {% raw %}`{{ article.published_at | date: "%Y" }}`{% endraw %}            | 2014                 |

The format for this syntax is the same as [`strftime`](http://strftime.net/).
