{# 主题 D（P2-12）：文章/列表页的 seo_description 由 scripts/seo-description.js 生成；
   未设置时传 undefined，open_graph 自动回退到 page.description / excerpt / config.description。
   og:image 只取首图（page.seo_image，同样由 seo-description.js 生成），不传时 open_graph 回退到正文全量扫描 #}
{%- if page.seo_image %}
  {{ open_graph({ description: page.seo_description, twitter_card: 'summary_large_image', images: [page.seo_image] }) }}
{%- else %}
  {{ open_graph({ description: page.seo_description, twitter_card: 'summary_large_image' }) }}
{%- endif %}

{{ canonical() }}

{# Exports some front-matter variables to Front-End #}
<script id="page-configurations">
  // https://hexo.io/docs/variables.html
  CONFIG.page = {
    sidebar: {{ page.sidebar | json }},
    isHome : {{ is_home() }},
    isPost : {{ is_post() }},
    lang   : '{{ page.lang }}'
  };
</script>
