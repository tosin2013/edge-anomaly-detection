# Camel K Ship integration 

The following camel-k script is used to connect Kafka to S3 and store the data in S3. The script first imports the necessary dependencies, including the camel-endpointdsl dependency which provides DSL support for Camel endpoints.
```
// dependency=camel:camel-endpointdsl
```
The script then defines a class called Kafka2S3Route which extends the RouteBuilder class. The RouteBuilder class is used to define Camel routes.
The Kafka2S3Route class defines a method called storeInS3() which is responsible for storing the data in S3. The method first creates a string that contains the AWS S3 access key, secret key, and region. This string is then used to create a URL for the AWS S3 endpoint.
```
String key = "accessKey=RAW(" + s3_accessKey + ")";
String secret = "&secretKey=RAW(" + s3_secretKey + ")";
String region = "&region=" + s3_region;
String s3params = key + secret + region;
```

The method then defines a Kafka route that consumes messages from the topic `CHANGEME`. The messages are converted to strings and then aggregated into groups of the specified size. The aggregated messages are then processed by a processor which merges them into a single string. The string is then set as the body of the exchange and the exchange is routed to the AWS S3 endpoint. The filename for the file in S3 is generated using the topic name, the Kafka key, and the current date.

```
from("kafka:CHANGEME?brokers=prod-kafka-cluster-kafka-bootstrap.edge-datalake.svc.cluster.local:9092")
            .doTry()
                .convertBodyTo(String.class)
                .aggregate(simple("true"), new GroupedBodyAggregationStrategy()).completionSize(s3_message_aggregation_count)
                .process(new Processor() {
                    @Override
                    public void process(Exchange exchange) throws Exception {
                        List<Exchange> data = exchange.getIn().getBody(List.class);
                        StringBuffer sb = new StringBuffer();
                        for (Iterator iterator = data.iterator(); iterator.hasNext();) {
                            String ex = (String) iterator.next();
                            sb.append(ex + "\\n");
                        }
                        exchange.getIn().setBody(new ByteArrayInputStream(sb.toString().getBytes()));
                    }
                })
                .setHeader(AWS2S3Constants.KEY, simple("edge-datalake-" + topicName + "-${headers[kafka.KEY]}-${date:now}.txt"))
                .to("aws2-s3://edge-anomaly-detection-w46h6?" + s3params)
                .log("Uploaded from [ ${headers[kafka.KEY]} ] " + topicName + " dataset to S3")
            .endDoTry()
            .doCatch(Exception.class)
                .log("Error processing topic: " + topicName + ". Moving to the next topic.")
.end();
```

The storeInS3() method also defines a doCatch() block which handles any exceptions that occur during the processing of the messages. The doCatch() block simply logs the exception and moves on to the next topic.
The Kafka2S3Route class also defines an onCompletion() method which is called when the route completes. The onCompletion() method does not do anything in this case.

To use this in the Camal K integration Operator take the Ship name and replace it with the `CHANGEME` in the script below.

Ship Names:
* `QueenMary` - already deployed in `edge-anomaly-detection`
* `Titanic` - already deployed in `edge-anomaly-detection`
*  Lusitania
*  Britannic
*  Aurora
*  Polaris
*  Voyager
*  Endeavor
*  Nautilus
  
Change the name of the Integration from `kafka-to-s3-integration-CHANGEME` in the script below. This will be the name `kafka-to-s3-integration-<Ship Name>`. make sure that it is lowercase 
Change the edge-anomaly-detection-CHANGEME to edge-anomaly-detection-$GUID in the script below. This will be the target s3 bucket name.

**Use the Script below:**
```
apiVersion: camel.apache.org/v1
kind: Integration
metadata:
  name: kafka-to-s3-integration-CHANGEME
  namespace: edge-datalake
spec:
  configuration:
    - type: configmap
      value: kafka-to-s3-config
    - type: secret
      value: s3-secret
  profile: OpenShift
  sources:
    - content: |
        // dependency=camel:camel-endpointdsl



        package com.redhat.manuela.routes;




        import java.io.ByteArrayInputStream;

        import java.util.Iterator;

        import java.util.List;


        import org.apache.camel.Exchange;

        import org.apache.camel.Processor;

        import org.apache.camel.PropertyInject;

        import org.apache.camel.builder.RouteBuilder;

        import org.apache.camel.component.aws2.s3.AWS2S3Constants;

        import
        org.apache.camel.builder.endpoint.dsl.AWS2S3EndpointBuilderFactory;

        import org.apache.camel.model.OnCompletionDefinition;

        import
        org.apache.camel.processor.aggregate.GroupedBodyAggregationStrategy;

        import org.slf4j.Logger;

        import org.slf4j.LoggerFactory;


        public class Kafka2S3Route extends RouteBuilder {

            private static final Logger LOGGER = LoggerFactory.getLogger(Kafka2S3Route.class);

            @PropertyInject("s3.custom.endpoint.enabled")
            private String s3_custom_endpoint_enabled;

            @PropertyInject("s3.custom.endpoint.url")
            private String s3_custom_endpoint_url;

            @PropertyInject("s3.accessKey")
            private String s3_accessKey;

            @PropertyInject("s3.secretKey")
            private String s3_secretKey;

            @PropertyInject("s3.message.aggregation.count")
            private String s3_message_aggregation_count;

            @PropertyInject("s3.region")
            private String s3_region;

            @Override
            public void configure()  {
                storeInS3();
            }

            private void storeInS3() {
                String key = "accessKey=RAW(" + s3_accessKey + ")";
                String secret = "&secretKey=RAW(" + s3_secretKey + ")";
                String region = "&region=" + s3_region;
                String s3params = key + secret + region;
                String topicName = "CHANGEME";

                from("kafka:CHANGEME?brokers=prod-kafka-cluster-kafka-bootstrap.edge-datalake.svc.cluster.local:9092")
                    .doTry()
                        .convertBodyTo(String.class)
                        .aggregate(simple("true"), new GroupedBodyAggregationStrategy()).completionSize(s3_message_aggregation_count)
                        .process(new Processor() {
                            @Override
                            public void process(Exchange exchange) throws Exception {
                                List<Exchange> data = exchange.getIn().getBody(List.class);
                                StringBuffer sb = new StringBuffer();
                                for (Iterator iterator = data.iterator(); iterator.hasNext();) {
                                    String ex = (String) iterator.next();
                                    sb.append(ex + "\\n");
                                }
                                exchange.getIn().setBody(new ByteArrayInputStream(sb.toString().getBytes()));
                            }
                        })
                        .setHeader(AWS2S3Constants.KEY, simple("edge-datalake-" + topicName + "-${headers[kafka.KEY]}-${date:now}.txt"))
                        .to("aws2-s3://edge-anomaly-detection-CHANGEME?" + s3params)
                        .log("Uploaded from [ ${headers[kafka.KEY]} ] " + topicName + " dataset to S3")
                    .endDoTry()
                    .doCatch(Exception.class)
                        .log("Error processing topic: " + topicName + ". Moving to the next topic.")
                .end();
            }

            @Override
            public OnCompletionDefinition onCompletion() {
                return super.onCompletion();
            }
        }
    name: kafka-to-s3-integration-olympic
```


## Sources
* [Industrial Edge](https://github.com/validatedpatterns/industrial-edge)
* [About Bobbycar - The Red Hat Connected Vehicle Architecture](https://github.com/sa-mw-dach/bobbycar)