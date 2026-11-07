'use strict';

/**
 * 主题 E-1：Lighthouse CI 配置。
 *
 * 用 `npx @lhci/cli autorun` 在 public/ 静态产物上跑审计，无需启动 hexo server：
 * LHCI 的 staticDistDir 会自己起 express 静态服务并解析中文路径。
 *
 * 断言先全部用 warn（不阻断），观察一周真实分数分布后再决定是否升 error。
 * LCP 阈值 3000ms：CI runner 的 CPU 比本地慢，本地 1.4–1.8s 在 CI 约 2.0–2.6s 属正常。
 */

module.exports = {
  ci: {
    collect: {
      staticDistDir: './public',
      // 首页、文章页、分类页、归档页；中文文章路径交给 LHCI 编码
      url: [
        '/',
        '/2026/10/31/%E4%BB%8E%E9%9B%B6%E6%90%AD%E5%BB%BA%E4%BD%A0%E8%87%AA%E5%B7%B1%E7%9A%84%E9%9D%99%E6%80%81%E5%8D%9A%E5%AE%A2/',
        '/categories/notes/',
        '/archives/'
      ],
      numberOfRuns: 3,
      settings: {
        chromeFlags: ['--no-sandbox', '--disable-dev-shm-usage']
      }
    },
    assert: {
      assertions: {
        'categories:performance': ['warn', { minScore: 0.9 }],
        'categories:accessibility': ['warn', { minScore: 0.95 }],
        'largest-contentful-paint': ['warn', { maxNumericValue: 3000 }],
        'cumulative-layout-shift': ['warn', { maxNumericValue: 0.1 }],
        'total-blocking-time': ['warn', { maxNumericValue: 200 }]
      }
    }
  }
};
