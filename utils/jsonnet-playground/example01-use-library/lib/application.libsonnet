local deployment = import './deployment.libsonnet';

{
  basicApplication(p):: {
    [p.appName + '-deployment']: deployment.basicDeployment(p),
  }
}