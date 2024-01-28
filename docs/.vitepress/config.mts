import { defineConfig } from 'vitepress';

export default defineConfig({
  title: 'Tenant Realm',
  description: 'Tenant Realm Doc',
  srcDir: './src',
  base: '/tenant_realm/',
  themeConfig: {
    nav: [
      {
        text: 'Guide',
        link: '/introduction/what-is-it',
      },
    ],
    sidebar: [
      {
        text: 'Introduction',
        items: [
          {
            text: 'What is Tenant Realm?',
            link: '/introduction/what-is-it',
          },
          {
            text: 'Getting Started',
            link: '/introduction/getting-started',
          },
          {
            text: 'Run Migration',
            link: '/introduction/run-migration',
          },
        ],
      },
      {
        text: 'Customization',
        items: [
          {
            text: 'CurrentTenant',
            link: '/customization/current-tenant',
          },
        ],
      },
      {
        text: 'API Reference',
        link: '/api-reference',
      },
    ],
    outline: {
      level: [2, 3],
      label: 'On this page',
    },
    lastUpdated: {
      text: 'Last updated',
      formatOptions: {
        dateStyle: 'full',
        timeStyle: 'medium',
      },
    },
    socialLinks: [
      {
        icon: 'github',
        link: 'https://github.com/zgid123/tenant_realm',
      },
    ],
  },
});
