---
title: uniq
---


<p>Removes any duplicate instances of an element in an array.</p>

| Input                                      | Output |
|:-------------------------------------------|:-------|
| {% raw %}`{% assign fruits = "orange apple banana apple orange" %} {{ fruits | split: ' ' | uniq | join: ' ' }}`{% endraw %} | orange apple banana      |
