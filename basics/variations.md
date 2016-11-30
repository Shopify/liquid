---
title: Variations of Liquid
description: An overview of the different installations of Liquid and how Liquid can change depending on where you're using it.
---

Liquid is a flexible, safe language, and is used in many different environments. Liquid was created for use in [Shopify](https://www.shopify.com) stores, and is also used extensively on [Jekyll](https://jekyllrb.com) websites. Over time, both Shopify and Jekyll have added their own objects, tags, and filters to Liquid. The most popular versions of Liquid that exist are **Liquid**, **Shopify Liquid**, and **Jekyll Liquid**.

This site documents the latest version of **Liquid** including betas and release candidates — that is, Liquid as it exists outside of Shopify and Jekyll. If you download the Liquid repository or install it as a [gem](https://rubygems.org/gems/liquid), you will get access to whatever objects, tags, and filters are in the version of Liquid that you chose.

## Shopify

Shopify always uses the latest version of Liquid as a base, but Shopify adds a significant number of objects, tags, and filters to Liquid for use in merchants' stores. These include objects representing store, product, and customer information, and filters for displaying store data and manipulating storefront assets like product images.

Shopify's version of Liquid is documented in the [Shopify Help Center](https://help.shopify.com/themes/liquid). If you want to try out Shopify's version of Liquid, you can [start a free trial of Shopify](https://www.shopify.com/signup) or use a sandbox like [DropPen](http://droppen.org/).

## Jekyll

[Jekyll](https://jekyllrb.com) is a static site generator, a command-line tool that creates websites by merging templates with content files. Jekyll uses Liquid as its template language, and adds a few objects, tags, and filters. These include objects representing content pages, tags for including snippets of content in others, and filters for manipulating strings and URLs.

Jekyll also powers [GitHub Pages](https://pages.github.com/), a web hosting service that lets you push a Jekyll installation to a GitHub repository and have the resulting website published. This website is built using GitHub Pages.

Jekyll might not be using the latest version of Liquid. This means that the tags and filters listed on this site may not work in Jekyll. Often the Jekyll project will wait for a stable release of Liquid rather than using a beta or release candidate version. To see what version of Liquid Jekyll is using, check the **runtime dependencies** section of [Jekyll's gem page](https://rubygems.org/gems/jekyll).

Jekyll's version of Liquid is documented in the [Templates section of Jekyll's documentation](http://jekyllrb.com/docs/templates/). If you want to try out Jekyll's version of Liquid, you can clone the Jekyll project or install Jekyll as a gem and test Liquid on a static site.
