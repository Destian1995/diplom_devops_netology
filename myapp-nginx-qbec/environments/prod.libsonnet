

// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    myapp_deployment +: {
        replicas: 4
        },
  }
}