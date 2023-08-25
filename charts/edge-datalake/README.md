# Testing Documentation

## Requirements
* Red hat Advanced Cluster Manager

This will deploy the edge-datalake chart in a test environment.  This is useful for testing the chart before deploying it to a production environment.
```
cd $HOME/edge-anomaly-detection
oc new-project edge-datalake
helm install charts/edge-datalake --dry-run --generate-name
helm install charts/edge-datalake --generate-name
```

## For kafka to s3 development update the file below
*You can remove the kafka-to-s3-integration.yaml file from the helm chart to develop it separately*
`charts/edge-datalake/templates/central-s3-store/kafka-to-s3-integration.yaml`

## Advanced options 
update the vaules.yaml file to change the default values for the chart.  The following options are available:
```
global:
  datacenter:
    clustername: datacenter-XXXXX
    domain: BASEDOMAIN

  s3:
    bucket:
      name: BUCKETNAME
      region: AWSREGION
      message:
        aggregation:
          count: 50
      custom:
        endpoint:
          enabled: false

clusterGroup:
  name: datacenter
  isHubCluster: true
  managedClusterGroups:
    factory:
      name: factory
      # repoURL: https://github.com/dagger-refuse-cool/manuela-factory.git
      # targetRevision: main
      helmOverrides:
      # Values must be strings!
      - name: clusterGroup.isHubCluster
        value: "false"
      clusterSelector:
#        matchLabels:
#          clusterGroup: factory
        matchExpressions:
        - key: vendor
          operator: In
          values:
            - OpenShift

kafka:
  broker:
    uri: "prod-kafka-cluster-kafka-bootstrap.edge-datalake.svc.cluster.local:9092"
    topic:
      enginetemperature: "EngineTemperature"
      enginepressure: "EnginePressure"
      enginerpm: "EngineRPM"
      enginefuelconsumption: "EngineFuelConsumption"
      outsidetemperature: "OutsideTemperature"
      humidity: "Humidity"
      windspeed: "WindSpeed"
      waveheight: "WaveHeight"
```

## Uninstall the chart
1. Find the release name of the chart. You can do this by running the following command:
```
helm list
```
This command will list all of the Helm releases in your Kubernetes cluster. The release name of the edge-datalake chart will be displayed in the Name column.

2. Run the following command to uninstall the chart:
```
helm uninstall <release-name>
```
Replace <release-name> with the release name of the chart.


## Troubleshooting
Restart the `engine-room-monitoring-` pod found in the `edge-anomaly-detection` namespace after each redeployment of the helm chart. This will ensure that kafka is receiving the data from the edge devices.
