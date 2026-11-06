{% extends 'page.swig' %}

{% block content %}
  <div class="post-block" lang="{{ page.lang or config.language }}">
    {% include '_partials/page/page-header.swig' %}
    <div class="post-body">
      <div class="not-found">
        <div class="not-found-emoji">🧭</div>
        <p class="not-found-text">迷路中……这一页不存在哦</p>
        <p class="not-found-hint">可能是链接打错了，也可能文章已经搬家。</p>
        <div class="not-found-actions">
          <a class="not-found-btn" href="/"><i class="fas fa-home"></i> 回首页</a>
          <button class="not-found-btn" id="randomGo" type="button"><i class="fas fa-dice"></i> 随机逛一逛</button>
        </div>
      </div>

      <script id="notFoundUrls" type="application/json">[
        {%- for post in site.posts %}"{{ post.url }}"{%- if not loop.last %},{% endif %}{%- endfor %}
      ]</script>
      <script>
        (function () {
          var btn = document.getElementById('randomGo');
          if (!btn) return;
          btn.addEventListener('click', function () {
            var urls = [];
            try {
              urls = JSON.parse(document.getElementById('notFoundUrls').textContent);
            } catch (e) {}
            if (urls.length) {
              location.href = urls[Math.floor(Math.random() * urls.length)];
            } else {
              location.href = '/';
            }
          });
        })();
      </script>
    </div>
  </div>
{% endblock %}
