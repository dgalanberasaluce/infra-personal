{
  basicDeployment(p):: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: p.appName + '-deployment',
      labels: {
        app: p.appName
      }
    },
  },
}