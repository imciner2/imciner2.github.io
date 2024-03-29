---
title: Publications
layout: publications
---

# Publications

<div>
  <div class="right-align">
    <p>
      <a class="button" href="{{ site.baseurl }}{% link publications-topic.md %}">By Topic</a>
      <a class="button" href="{{ site.baseurl }}{% link publications-year.md %}">By Year</a>
      <a class="button" href="{{ site.baseurl }}{% link publications.md %}">By Type</a>
    </p>
  </div>
</div>

{% bibliography_bytype --file Papers --query @unpublished --style ./content/bibliographies/display_style.csl %}
<br>

{% bibliography_bytype --file Papers --query @article --style ./content/bibliographies/display_style.csl %}
<br>

{% bibliography_bytype --file Papers --query @inproceedings --style ./content/bibliographies/display_style.csl %}
<br>

{% bibliography_bytype --file Papers --query @thesis --style ./content/bibliographies/display_style.csl %}
<br>

{% bibliography_bytype --file Papers  --query @techreport --style ./content/bibliographies/display_style.csl %}
<br>

{% bibliography_bytype --file Papers --query @patent --style ./content/bibliographies/display_style.csl %}
<br>

**Copyright disclaimer:** The documents contained in this page are included to ensure timely dissemination of scholarly and technical work on a non-commercial basis. Copyright and all rights therein are maintained by the authors or by other copyright holders, notwithstanding that they have offered their works here electronically. It is understood that all persons copying this information will adhere to the terms and constraints invoked by each author's copyright. These works may not be reposted without the explicit permission of the copyright holder.
