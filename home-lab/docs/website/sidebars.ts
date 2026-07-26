import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  tutorialSidebar: [
    'index',
    {
      type: 'category',
      label: 'Applications',
      items: [
        'apps/openbao',
      ],
    },
    {
      type: 'category',
      label: 'Forgejo',
      items: [
        // 'forgejo/forgejo-actions',
        'forgejo/forgejo-runner',
        'forgejo/renovate'
      ]
    },
    {
      type: 'category',
      label: 'Core Apps',
      items: [
        'core/http-proxy',
        'core/internal-dns'
      ]
    },
    'ansible/README'
  ],
};

export default sidebars;
