# Renovate
## Create a Renovate Bot account
Forgejo does not support _service accounts_. Although it is not strictly necessary, it is a good practice to create a dedicated user for Renovate Bot. This way, I can easily track the changes made by Renovate and manage its permissions separately from the personal account.

Create a new user in Forgejo:
- User: `renovate-bot`
- Mail: `renovatebot@forgejo.internal`
- Update profile image to use Renovate's logo (optional)


**Create a renovate configuration repository (logged as renovate bot account):**
- Repository: `renovate-config`
- Create a file `config.js`:

```js
module.exports = {
	platform: 'gitea',
	endpoint: 'https://example.com/api/v1/', // set this to the url of the forgejo instance
	gitAuthor: 'Renovate Bot <renovatebot@forgejo.internal>', 
	username: 'renovate-bot',
	autodiscover: true,
	onboardingConfig: {
		$schema: 'https://docs.renovatebot.com/renovate-schema.json',
		extends: ['config:recommended'],
	},
	optimizeForDisabled: true,
	persistRepoData: true,

	allowCustomCrateRegistries: true, // Allows extensions like .json5. It should be enabled by default
};
```

**Configure a Renovate's Workflow (Forgejo Actions):**
- Create file `.forgejo/workflows/renovate.yaml`:

```yaml
name: renovate
run-name: >-
  ${{ github.event_name == 'schedule' && 'Scheduled Renovate Run' || 
      github.event_name == 'workflow_dispatch' && format('Manual Run by @{0}', github.actor) || 
      format('Push: {0}', github.event.head_commit.message) }}

on:
  workflow_dispatch:
    branches:
      - main
  schedule: 
    - cron: "0 12 * * *"
  push:
    branches:
      - main

jobs:
  renovate:
    runs-on: ubuntu-latest
    container: ghcr.io/renovatebot/renovate:latest
    steps:
      - uses: actions/checkout@v6
      - run: renovate
        env:
          RENOVATE_CONFIG_FILE: ${{ forge.workspace }}/config.js
          LOG_LEVEL: "info"
          RENOVATE_TOKEN: ${{ secrets.RENOVATE_TOKEN }}
          RENOVATE_GITHUB_COM_TOKEN: ${{ secrets.RENOVATE_GITHUB_COM_TOKEN }} # Integration with Github
```

**Create authentication token:**
- (Logged as renovate bot) (User) Settings > Applications > Access tokens > Generate new token
    - Name: `renovate-token`
    - Permissions:
        - `read:misc`
        - `read:notification`
        - `read:organization`
        - `read:package`
        - `write:issue`
        - `write:repository`
        - `read:user`
- Add the token as a secret in the `renovate-config` repository:
    - Repository: `renovate-config` > Settings > Actions > Secrets > add Secret


## Integration with Github

**Create `RENOVATE_GITHUB_COM_TOKEN` secret**

- Github: Settings > Developer settings > Personal access tokens > Fine-grained tokens > Generate new token
    - Repository access: Public repositories
    - Token name: `forgejo-renovatebot-public-readonly`
- Forgejo: > renovate-bot/renovate-config > Settings > Actions > Secrets > add Secret > `RENOVATE_GITHUB_COM_TOKEN`


## Resources
- [Set up Gitea, Renovate and Komodo](https://nickcunningh.am/blog/how-to-automate-version-updates-for-your-self-hosted-docker-containers-with-gitea-renovate-and-komodo)
- [Set up Forgejo, Forgejo Actions and OAuth2](https://nickcunningh.am/blog/how-to-setup-and-configure-forgejo-with-support-for-forgejo-actions-and-more)


## Integrate Renovate on a repository
- Add the `renovate-bot` user as collaborator of the project repository
    - Repository > Settings > Collaborators > Add `renovate-bot`
- Create `renovate.json` file in the root directory of the repository with the following content:
```jsonc
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  //...
}
