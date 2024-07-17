---
title: Publications
layout: publications
---

# Publications

<div>
  <div class="right-align">
    <p>
      <button class="button button-bib left-align" onclick="toggleBibliography('type')">By Type</button>
      <button class="button button-bib left-align" onclick="toggleBibliography('year')">By Year</button>
      <button class="button button-bib left-align" onclick="toggleBibliography('topic')">By Topic</button>
    </p>
  </div>
</div>

<div id="bibliography-type">
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
</div>

<div id="bibliography-topic" style="display: none;">
{% bibliography_keyword --file Papers --style ./content/bibliographies/display_style.csl %}
</div>

<div id="bibliography-year" style="display: none;">
{% bibliography_year --file Papers --style ./content/bibliographies/display_style.csl %}
</div>


**Copyright disclaimer:** The documents contained in this page are included to ensure timely dissemination of scholarly and technical work on a non-commercial basis. Copyright and all rights therein are maintained by the authors or by other copyright holders, notwithstanding that they have offered their works here electronically. It is understood that all persons copying this information will adhere to the terms and constraints invoked by each author's copyright. These works may not be reposted without the explicit permission of the copyright holder.
