{% extends 'page.swig' %}

{% block content %}
  <div class="post-block" lang="{{ page.lang or config.language }}">
    {% include '_partials/page/page-header.swig' %}
    <div class="post-body">
      <div class="secret-gate">
        <div class="secret-lock"><i class="fas fa-lock"></i></div>

        {%- if page.locked %}
          <div id="secretForm">
            <input class="secret-input" id="secretPass" type="password" autocomplete="off" placeholder="输入密码">
            <button class="secret-btn" id="secretBtn" type="button">解 锁</button>
            <p class="secret-error" id="secretError"></p>
          </div>
          <script id="secretCipher" type="application/json">{{ page.cipher }}</script>
        {%- endif %}

        <div class="secret-list" id="secretList"></div>
        <p class="secret-empty" id="secretEmpty" style="display:none">这里还没有内容</p>
        <p class="secret-hint">此分区内容仅对自己可见入口，解锁本次会话内有效</p>
      </div>

      <script>
        (function () {
          'use strict';

          var STORE_OK = 'secret-unlocked';
          var STORE_LIST = 'secret-list';
          var locked = {{ 'true' if page.locked else 'false' }};
          {% if page.locked %}
          var cipherText = document.getElementById('secretCipher').textContent.trim();
          {% else %}
          var plainList = {{ page.posts_json | safe }} || [];
          {% endif %}

          var listEl = document.getElementById('secretList');
          var emptyEl = document.getElementById('secretEmpty');
          var formEl = document.getElementById('secretForm');

          function renderList(items) {
            if (formEl) formEl.style.display = 'none';
            listEl.innerHTML = '';
            if (!items.length) {
              emptyEl.style.display = '';
              return;
            }
            items.forEach(function (item) {
              var a = document.createElement('a');
              a.className = 'secret-item';
              a.href = '/' + item.u;
              var date = document.createElement('span');
              date.className = 'secret-item-date';
              date.textContent = item.d;
              var title = document.createElement('span');
              title.className = 'secret-item-title';
              title.textContent = item.t;
              a.appendChild(date);
              a.appendChild(title);
              listEl.appendChild(a);
            });
          }

          function b64ToBuf(b64) {
            var bin = atob(b64);
            var arr = new Uint8Array(bin.length);
            for (var i = 0; i < bin.length; i++) arr[i] = bin.charCodeAt(i);
            return arr;
          }

          function unlock(pass) {
            var raw = b64ToBuf(cipherText);
            var salt = raw.slice(0, 16);
            var iv = raw.slice(16, 28);
            var data = raw.slice(28); // ciphertext + GCM tag 连续存放（salt 16 + iv 12 之后全是密文）
            var derivedKey = null;
            return crypto.subtle.importKey('raw', new TextEncoder().encode(pass), 'PBKDF2', false, ['deriveKey'])
              .then(function (keyMat) {
                // extractable=true：解锁后导出 JWK 存 sessionStorage，私密文章页凭它解密正文
                return crypto.subtle.deriveKey(
                  { name: 'PBKDF2', salt: salt, iterations: 120000, hash: 'SHA-256' },
                  keyMat, { name: 'AES-GCM', length: 256 }, true, ['decrypt']);
              })
              .then(function (key) {
                derivedKey = key;
                return crypto.subtle.decrypt({ name: 'AES-GCM', iv: iv }, key, data);
              })
              .then(function (plain) {
                return crypto.subtle.exportKey('jwk', derivedKey).then(function (jwk) {
                  sessionStorage.setItem('secret-key', JSON.stringify(jwk));
                  return JSON.parse(new TextDecoder().decode(plain));
                });
              });
          }

          function showError(msg) {
            var errEl = document.getElementById('secretError');
            if (errEl) errEl.textContent = msg;
          }

          function onUnlocked(items) {
            sessionStorage.setItem(STORE_OK, '1');
            sessionStorage.setItem(STORE_LIST, JSON.stringify(items));
            sessionStorage.removeItem('secret-post-retry');
            // 从某篇私密文章被守卫拦到门页的，解锁后直接送回去
            var back = sessionStorage.getItem('secret-return');
            if (back) {
              sessionStorage.removeItem('secret-return');
              location.replace(back);
              return;
            }
            renderList(items);
          }

          if (!locked) {
            renderList(plainList || []);
          } else if (sessionStorage.getItem(STORE_OK) === '1' && sessionStorage.getItem(STORE_LIST)) {
            try {
              renderList(JSON.parse(sessionStorage.getItem(STORE_LIST)));
            } catch (e) {
              sessionStorage.removeItem(STORE_OK);
              sessionStorage.removeItem(STORE_LIST);
            }
          }

          if (locked && formEl) {
            document.getElementById('secretBtn').addEventListener('click', function () {
              var pass = document.getElementById('secretPass').value;
              if (!pass) return;
              unlock(pass)
                .then(onUnlocked)
                .catch(function () {
                  // 失败可能是浏览器缓存了旧页面（每次构建盐值都会变）：
                  // 先悄悄取一次当前密文比对，变了就强制刷新重试，没变才判定密码错
                  fetch('/secret/?fresh=' + Date.now(), { cache: 'no-store' })
                    .then(function (r) { return r.text(); })
                    .then(function (html) {
                      var m = html.match(/id="secretCipher" type="application\/json">([^<]*)</);
                      if (m && m[1].trim() !== cipherText) {
                        location.replace('/secret/?fresh=' + Date.now());
                        return;
                      }
                      showError('密码不对，再想想？');
                    })
                    .catch(function () { showError('密码不对，再想想？'); });
                });
            });
            document.getElementById('secretPass').addEventListener('keydown', function (e) {
              if (e.key === 'Enter') document.getElementById('secretBtn').click();
            });
          }
        })();
      </script>
    </div>
  </div>
{% endblock %}
