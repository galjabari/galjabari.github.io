---
layout: default
title: Home
---

# Welcome

I'm Ghannam Aljabari, a Network and Systems Engineer passionate about Network Automation, Cybersecurity, and Cloud Computing.

## Blog Posts

<ul>
{% for post in site.pages %}
  {% if post.path contains 'blog/' %}
    <li><a href="{{ post.url }}">{{ post.title }}</a></li>
  {% endif %}
{% endfor %}
</ul>

[About Me](about.md)
