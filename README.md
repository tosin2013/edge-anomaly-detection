# edge-anomaly-detection
This repository contains the code for a workshop on how to use different tools to monitor and manage an edge-anomaly-detection application. The workshop covers the following topics:

* Checking the Prometheus charts for the application
* Viewing the Kafka messages under the data lake project
* Configuring Camel K Ship integration

`There will be more topics added in the future.`

This workshop will teach you how to use different tools to monitor and manage your edge-anomaly-detection application.

In the first part of the workshop, you will learn how to check the Prometheus charts for your application. Prometheus is a monitoring system that can be used to collect and store metrics from your application. The Prometheus charts will show you how your application is performing over time.

In the second part of the workshop, you will learn how to view the Kafka messages under the data lake project. Kafka is a distributed streaming platform that can be used to process and store data streams. The Kafka messages will show you the data that is being processed by your application in real time.

In the third part of the workshop, you will learn how to configure Camel K Ship integration. Camel K is a Kubernetes-native integration framework that can be used to connect different applications and systems. The Camel K Ship integration will allow you to send data from your application to the data lake.


## Requirements
- OpenShift 4.14+
- Bastion host to use to deploy the demo

**Quick Start**

*Testing on RHEL 8 jumpbox*
```
curl -OL https://raw.githubusercontent.com/tosin2013/redhat-edge-ai-industrial-demo-infra/main/dev-box.sh
chmod +x dev-box.sh
./dev-box.sh
```

## Demo/Workshop instructions
[Instructions](workshop/README.md)

## Contributing
[Contributing](docs/setup-bastion-doc.md)