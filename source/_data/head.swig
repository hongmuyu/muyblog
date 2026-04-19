{# ============================================ #}
{# 性能优化和SEO头部标签 #}
{# 这些标签会插入到HTML的<head>部分 #}
{# ============================================ #}

{# 预加载关键资源 #}
<link rel="preload" href="/css/main.css" as="style">
<link rel="preload" href="/js/main.js" as="script">

{# 预连接重要第三方域名 #}
<link rel="preconnect" href="https://cdnjs.cloudflare.com">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="preconnect" href="https://giscus.app">
<link rel="preconnect" href="https://raw.githubusercontent.com">

{# DNS预获取 #}
<link rel="dns-prefetch" href="//zouwenxiang.cn">
<link rel="dns-prefetch" href="//cdnjs.cloudflare.com">
<link rel="dns-prefetch" href="//fonts.googleapis.com">
<link rel="dns-prefetch" href="//fonts.gstatic.com">
<link rel="dns-prefetch" href="//giscus.app">
<link rel="dns-prefetch" href="//raw.githubusercontent.com">

{# 异步加载非关键CSS #}
<link rel="preload" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"></noscript>

{# 关键CSS内联（可选） #}
{# 如果需要进一步优化首屏渲染，可以考虑内联关键CSS #}

{# 资源提示 #}
<link rel="prefetch" href="/search.xml" as="document">
<link rel="prefetch" href="/js/local-search.js" as="script">

{# 浏览器缓存控制 #}
<meta http-equiv="Cache-Control" content="public, max-age=3600">
<meta http-equiv="Expires" content="{{ now | date('r', 3600) }}">

{# PWA支持（基础） #}
<meta name="theme-color" content="#667eea">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">

{# 性能监控（可选） #}
{# 可以添加Google Analytics或自定义性能监控脚本 #}

{# 结构化数据（SEO）- 由 Hexo 生成器自动处理 #}
{# 如果需要自定义结构化数据，请使用 Hexo 插件或主题配置 #}

{# 移动端优化 #}
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, viewport-fit=cover">
<meta name="HandheldFriendly" content="true">
<meta name="MobileOptimized" content="width">

{# 防止被转码（百度等） #}
<meta http-equiv="Cache-Control" content="no-transform">
<meta http-equiv="Cache-Control" content="no-siteapp">

{# 禁止自动检测电话号码和邮箱 #}
<meta name="format-detection" content="telephone=no">
<meta name="format-detection" content="email=no">

{# 性能优化脚本 #}
<script>
// 异步加载字体
(function() {
  // 系统字体栈，优先使用系统字体
  var systemFontStack = '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif';

  // 如果不需要自定义字体，直接使用系统字体
  document.documentElement.style.setProperty('--font-system', systemFontStack);

  // 监控Web字体加载
  if ('fonts' in document) {
    document.fonts.ready.then(function() {
      document.documentElement.classList.add('fonts-loaded');
    });
  }
})();

// 资源加载优化
(function() {
  // 图片懒加载增强
  if ('IntersectionObserver' in window) {
    var lazyImages = document.querySelectorAll('img[loading="lazy"]');

    var imageObserver = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        if (entry.isIntersecting) {
          var img = entry.target;
          img.classList.add('loaded');
          imageObserver.unobserve(img);
        }
      });
    });

    lazyImages.forEach(function(img) {
      imageObserver.observe(img);
    });
  }

  // 延迟加载非关键脚本
  window.addEventListener('load', function() {
    var deferredScripts = document.querySelectorAll('script[data-defer]');
    deferredScripts.forEach(function(script) {
      var newScript = document.createElement('script');
      if (script.src) newScript.src = script.src;
      if (script.textContent) newScript.textContent = script.textContent;
      document.body.appendChild(newScript);
    });
  });
})();
</script>

{# 性能监控脚本（轻量级） #}
<script>
// 监控核心性能指标
if (window.performance) {
  window.addEventListener('load', function() {
    setTimeout(function() {
      var timing = performance.timing;
      var metrics = {
        dns: timing.domainLookupEnd - timing.domainLookupStart,
        tcp: timing.connectEnd - timing.connectStart,
        ttfb: timing.responseStart - timing.requestStart,
        domReady: timing.domContentLoadedEventEnd - timing.navigationStart,
        load: timing.loadEventEnd - timing.navigationStart
      };

      // 可以在这里发送性能数据到分析服务
      console.log('性能指标:', metrics);

      // 如果TTFB过慢，提示用户
      if (metrics.ttfb > 1000) {
        console.warn('服务器响应时间较慢:', metrics.ttfb + 'ms');
      }
    }, 0);
  });
}

// 监控CLS（布局偏移）
if ('PerformanceObserver' in window) {
  var clsObserver = new PerformanceObserver(function(list) {
    var entries = list.getEntries();
    entries.forEach(function(entry) {
      if (entry.hadRecentInput) return;
      console.log('布局偏移检测:', entry);
    });
  });

  try {
    clsObserver.observe({type: 'layout-shift', buffered: true});
  } catch (e) {
    console.log('CLS监控不支持:', e);
  }
}
</script>