---
title: Iteration
---

Iteration Tags are used to run a block of code repeatedly.

## for

Repeatedly executes a block of code. For a full list of attributes available within a `for` loop, see [forloop (object)](/themes/liquid-documentation/objects/for-loops).

`for` loops can output a maximum of 50 results per page. In cases where there are more than 50 results, use the [paginate](/themes/liquid-documentation/tags/theme-tags/#paginate) tag to split them across multiple pages.

```liquid
{% raw %}
  {% for product in collection.products %}
    {{ product.title }}
  {% endfor %}
{% endraw %}
```

```text
hat shirt pants
```

### break

Causes the loop to stop iterating when it encounters the `break` tag.

```liquid
{% raw %}
{% for i in (1..5) %}
  {% if i == 4 %}
    {% break %}
  {% else %}
    {{ i }}
  {% endif %}
{% endfor %}
{% endraw %}
```

```text
1 2 3
```

### continue

Causes the loop to skip the current iteration when it encounters the `continue` tag.

```liquid
{% raw %}
{% for i in (1..5) %}
  {% if i == 4 %}
    {% continue %}
  {% else %}
    {{ i }}
  {% endif %}
{% endfor %}
{% endraw %}
```

```text
1 2 3   5
```

## for (parameters)

### limit

Exits the for loop at a specific index.

```liquid
{% raw %}
<!-- if array = [1,2,3,4,5,6] -->
{% for item in array limit:2 %}
  {{ item }}
{% endfor %}
{% endraw %}
```

```text
1 2
```

### offset

Starts the for loop at a specific index.

```liquid
{% raw %}
<!-- if array = [1,2,3,4,5,6] -->
{% for item in array offset:2 %}
  {{ item }}
{% endfor %}
{% endraw %}
```

```text
3 4 5 6
```

### range

Defines a range of numbers to loop through. The range can be defined by both literal and variable numbers.

```liquid
{% raw %}
{% assign num = 4 %}
{% for i in (1..num) %}
  {{ i }}
{% endfor %}

{% for i in (3..5) %}
  {{ i }}
{% endfor %}
{% endraw %}
```

```text
1 2 3 4
3 4 5
```

### reversed

Reverses the order of the for loop.

```liquid
{% raw %}
<!-- if array = [1,2,3,4,5,6] -->
{% for item in array reversed %}
  {{ item }}
{% endfor %}
{% endraw %}
```

```text
6 5 4 3 2 1
```

## cycle

Loops through a group of strings and outputs them in the order that they were passed as parameters. Each time `cycle` is called, the next string that was passed as a parameter is output.

`cycle` must be used within a [for](#for) loop block.

```liquid
{% raw %}
{% cycle 'one', 'two', 'three' %}
{% cycle 'one', 'two', 'three' %}
{% cycle 'one', 'two', 'three' %}
{% cycle 'one', 'two', 'three' %}
{% endraw %}
```

```text
one
two
three
one
```

Uses for `cycle` include:

-   applying odd/even classes to rows in a table
-   applying a unique class to the last product thumbnail in a row

## cycle (parameters)

`cycle` accepts a parameter called `cycle group` in cases where you need multiple `cycle` blocks in one template. If no name is supplied for the cycle group, then it is assumed that multiple calls with the same parameters are one group.

## tablerow

Generates an HTML table. Must be wrapped in opening `<table>` and closing `</table>` HTML tags.

```liquid
{% raw %}
<table>
{% tablerow product in collection.products %}
  {{ product.title }}
{% endtablerow %}
</table>
{% endraw %}
```

```html
<table>
  <tr class="row1">
    <td class="col1">
      Cool Shirt
    </td>
    <td class="col2">
      Alien Poster
    </td>
    <td class="col3">
      Batman Poster
    </td>
    <td class="col4">
      Bullseye Shirt
    </td>
    <td class="col5">
      Another Classic Vinyl
    </td>
    <td class="col6">
      Awesome Jeans
    </td>
  </tr>
</table>
```

## tablerow (parameters)

#### cols

Defines how many columns the tables should have.

```liquid
{% raw %}
{% tablerow product in collection.products cols:2 %}
  {{ product.title }}
{% endtablerow %}
{% endraw %}
```

```html
<table>
  <tr class="row1">
    <td class="col1">
      Cool Shirt
    </td>
    <td class="col2">
      Alien Poster
    </td>
  </tr>
  <tr class="row2">
    <td class="col1">
      Batman Poster
    </td>
    <td class="col2">
      Bullseye Shirt
      </td>
  </tr>
  <tr class="row3">
    <td class="col1">
          Another Classic Vinyl
      </td>
    <td class="col2">
          Awesome Jeans
      </td>
  </tr>
</table>
```

#### limit

Exits the tablerow after a specific index.

```liquid
{% raw %}
{% tablerow product in collection.products cols:2 limit:3 %}
  {{ product.title }}
{% endtablerow %}
{% endraw %}
```

#### offset

Starts the tablerow after a specific index.

```liquid
{% raw %}
{% tablerow product in collection.products cols:2 offset:3 %}
  {{ product.title }}
{% endtablerow %}
{% endraw %}
```

#### range

Defines a range of numbers to loop through. The range can be defined by both literal and variable numbers.

```liquid
{% raw %}
<!--variable number example-->

{% assign num = 4 %}
<table>
{% tablerow i in (1..num) %}
  {{ i }}
{% endtablerow %}
</table>

<!--literal number example-->

<table>
{% tablerow i in (3..5) %}
  {{ i }}
{% endtablerow %}
</table>
{% endraw %}
```
