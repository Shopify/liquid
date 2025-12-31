# Liquid Compiled Template Optimization Log

This document tracks optimizations made to the compiled Liquid template engine.
Each entry shows before/after code and measured impact.

---

## Baseline Measurement

**Date:** 2024-12-31
**Commit:** (pending profiler implementation)

### Current State

The compiled template engine generates Ruby code from Liquid templates.
Before optimizations, here's a sample of generated code for a simple loop:

```ruby
# Template: {% for product in products %}{{ forloop.index }}: {{ product.name }}{% endfor %}

->(assigns, __context__, __external__) do
  __output__ = +""
  
  __coll1__ = assigns["products"]
  __coll1__ = __coll1__.to_a if __coll1__.is_a?(Range)
  __len3__ = __coll1__.respond_to?(:length) ? __coll1__.length : 0
  __idx2__ = 0
  catch(:__loop__break__) do
    (__coll1__.respond_to?(:each) ? __coll1__ : []).each do |__item__|
      catch(:__loop__continue__) do
        assigns["product"] = __item__
        assigns['forloop'] = {
          'name' => "product-products",
          'length' => __len3__,
          'index' => __idx2__ + 1,
          'index0' => __idx2__,
          'rindex' => __len3__ - __idx2__,
          'rindex0' => __len3__ - __idx2__ - 1,
          'first' => __idx2__ == 0,
          'last' => __idx2__ == __len3__ - 1,
        }
        __output__ << LR.output(LR.lookup(assigns["forloop"], "index", __context__))
        __output__ << ": "
        __output__ << LR.output(LR.lookup(assigns["product"], "name", __context__))
      end
      __idx2__ += 1
    end
  end
  assigns.delete("product")
  assigns.delete('forloop')
  
  __output__
end
```

### Issues Identified

1. **catch/throw overhead** - Used even when no break/continue in loop
2. **Hash allocation per iteration** - 8 key/value pairs computed every time
3. **respond_to? checks** - Redundant after type is known
4. **LR.lookup for forloop** - Unnecessary indirection for known hash
5. **String literals not frozen** - Allocates on each render
6. **Output buffer grows dynamically** - No pre-allocation

---

## Optimization Log

<!-- Entries will be added here as optimizations are implemented -->

