{% extends 'page.swig' %}

{% block content %}
  <div class="post-block" lang="{{ page.lang or config.language }}">
    {% include '_partials/page/page-header.swig' %}
    <div class="post-body">
      {%- if page.subtitle %}
        <p class="charts-subtitle">{{ page.subtitle }}</p>
      {%- endif %}

      <div class="chart-summary">
        <div class="chart-stat">
          <strong>{{ page.totalWords }}</strong>
          <span>全站字数</span>
        </div>
        <div class="chart-stat">
          <strong>{{ site.posts.length }}</strong>
          <span>文章</span>
        </div>
        <div class="chart-stat">
          <strong>{{ site.categories.length }}</strong>
          <span>分类</span>
        </div>
        <div class="chart-stat">
          <strong>{{ site.tags.length }}</strong>
          <span>标签</span>
        </div>
      </div>

      <div class="chart-section">
        <h3><i class="fas fa-folder-open"></i> 分类分布</h3>
        {%- for row in page.categories %}
          <div class="chart-row">
            <span class="chart-label">{{ row.name }}</span>
            <span class="chart-track">
              <span class="chart-bar" style="width: {{ row.percent }}%"></span>
            </span>
            <span class="chart-count">{{ row.count }}</span>
          </div>
        {%- endfor %}
      </div>

      <div class="chart-section">
        <h3><i class="fas fa-tags"></i> 标签 Top 10</h3>
        {%- for row in page.tags %}
          <div class="chart-row">
            <span class="chart-label">{{ row.name }}</span>
            <span class="chart-track">
              <span class="chart-bar" style="width: {{ row.percent }}%"></span>
            </span>
            <span class="chart-count">{{ row.count }}</span>
          </div>
        {%- endfor %}
      </div>

      <div class="chart-section">
        <h3><i class="fas fa-calendar-alt"></i> 年度发文</h3>
        {%- for row in page.years %}
          <div class="chart-row">
            <span class="chart-label">{{ row.name }}</span>
            <span class="chart-track">
              <span class="chart-bar" style="width: {{ row.percent }}%"></span>
            </span>
            <span class="chart-count">{{ row.count }}</span>
          </div>
        {%- endfor %}
      </div>
    </div>
  </div>
{% endblock %}
