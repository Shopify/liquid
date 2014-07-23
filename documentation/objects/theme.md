---
layout: default
title: theme

nav:
  group: Liquid Variables
---

# theme

The <code>theme</code> object contains information about published themes in a shop. You can also use <code>themes</code> to iterate through both themes.

<p class="input">Input</p>
{% highlight html %}{% raw %}
{% for t in themes %}
	{{ t.role }} theme: {{ t.name }}
{% endfor %}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
mobile theme: minimal
main theme: radiance
{% endraw %}{% endhighlight %}
</div>

The <code>theme</code> object has the following attributes: 

<a id="topofpage"></a>
{% table_of_contents %}





{% anchor_link "theme.id", "theme-id" %}

Returns the theme's id. This is useful for when you want to link a user directly to the theme's Theme Settings.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
Go to your <a href="/admin/themes/{{ theme.id }}/settings">theme settings</a> to change your logo. 
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Go to your <a href="/admin/themes/8196497/settings">theme settings</a> to change your logo. 
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "theme.role", "theme-role" %}

Returns one of the two possible roles of a theme: <code>main</code> or <code>mobile</code>.







{% anchor_link "theme.name", "theme-name" %}

Returns the name of the theme. 





