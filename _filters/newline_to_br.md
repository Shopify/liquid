---
title: newline_to_br
---

Replace every newline (`n`) with an HTML break (`<br>`).

| Code                                                   | Output             |
|-------------------------------------------------------:|:-------------------|
| {% raw %}`{{ "hello\nthere" | newline_to_br }}`{% endraw %}     | `hello<br/>there` |
