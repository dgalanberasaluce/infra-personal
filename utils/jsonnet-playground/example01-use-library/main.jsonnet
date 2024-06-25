local params = import './parameters.libsonnet';
local app = import './lib/application.libsonnet';

(app.basicApplication({
  appName: params.appName,
}))
