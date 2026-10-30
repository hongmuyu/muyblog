{% extends 'page.swig' %}

{% block content %}
  <div class="post-block" lang="{{ page.lang or config.language }}">
    {% include '_partials/page/page-header.swig' %}
    <div class="post-body">
      {%- if page.subtitle %}
        <p class="links-subtitle">{{ page.subtitle }}</p>
      {%- endif %}

      <div class="friend-links">
        {%- for link in page.links %}
          <a class="friend-card" href="{{ link.url }}" target="_blank" rel="noopener nofollow">
            {%- if link.avatar %}
              <img class="friend-avatar" src="{{ link.avatar }}" alt="{{ link.name }}" loading="lazy">
            {%- endif %}
            <span class="friend-name">{{ link.name }}</span>
            <span class="friend-desc">{{ link.desc }}</span>
          </a>
        {%- endfor %}

        <div class="friend-card friend-apply">
          <span class="friend-name"><i class="fas fa-link"></i> 申请友链</span>
          <span class="friend-desc">修改本站仓库的 source/_data/links.yml 提交 PR，或通过侧栏邮箱联系我</span>
        </div>
      </div>

      <div class="links-note">
        <p>添加友链只需编辑仓库中的 <code>source/_data/links.yml</code>，保存推送后卡片墙自动更新。</p>
      </div>
    </div>
  </div>
{% endblock %}
