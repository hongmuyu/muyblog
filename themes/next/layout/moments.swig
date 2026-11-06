{% extends 'page.swig' %}

{% block content %}
  <div class="post-block" lang="{{ page.lang or config.language }}">
    {% include '_partials/page/page-header.swig' %}
    <div class="post-body">
      {%- if page.subtitle %}
        <p class="moments-subtitle">{{ page.subtitle }}</p>
      {%- endif %}

      <div class="moments-list">
        {%- for moment in page.moments %}
          <div class="moment-item">
            <div class="moment-dot"></div>
            <div class="moment-card">
              <div class="moment-meta">
                {%- if moment.mood %}
                  <span class="moment-mood">{{ moment.mood }}</span>
                {%- endif %}
                <span class="moment-time">{{ moment.date }}</span>
              </div>
              <div class="moment-content">{{ moment.content }}</div>
            </div>
          </div>
        {%- endfor %}

        {%- if page.moments.length === 0 %}
          <div class="moment-empty">还没有碎碎念，敬请期待～</div>
        {%- endif %}
      </div>
    </div>
  </div>
{% endblock %}
