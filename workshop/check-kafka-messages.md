## Tutorial: Viewing Kafka Messages and Integrating with AWS S3 on the Data Lake Project

### Prerequisites:
- Access to the OpenShift environment.
- Familiarity with Kafka, Camel K, and AWS S3.

### Step 1: Access Kafka Messages
1. Open your OpenShift dashboard.
2. Navigate to the `edge-datalake` project route.
3. Click on the route for `kafdrop`.
   
   ![Kafdrop route](https://i.imgur.com/hsXB7q8.png)

4. Once inside, click on the `kafdrop` route to view the messages.
   
   ![Kafdrop messages](https://i.imgur.com/lM68h3n.png)

5. To view specific messages, click on a ship name, such as `Ship name`.
   
   ![Ship messages](https://i.imgur.com/xjHp4wk.png)

   ![Ship messages details](https://i.imgur.com/xs01w9Z.png)

6. Explore other ships within Kafka as needed.

### Step 2: View Camel-K Integration
1. Within the `edge-datalake` project, click on the `camel-k operator`.
   
   ![Camel-K operator](https://i.imgur.com/l4JLr0a.png)

   ![Camel-K details](https://i.imgur.com/Yvbah4B.png)

2. Review the code for `kafka-to-s3-integration-olympic`.
   
   ![Kafka to S3 integration](https://i.imgur.com/MVGWHQW.png)

3. Navigate to `Resources` and click on `Pod`.
   
   ![Resources Pod](https://i.imgur.com/iW2q0uB.png)

4. View the logs within the selected pod.
   
   ![Pod logs](https://i.imgur.com/qPYVzQc.png)

### Step 3: Access AWS Console and View S3 Bucket
1. Log in to your AWS console.
2. Navigate to the S3 service and locate the relevant bucket.
   
   ![AWS S3 bucket](https://i.imgur.com/kuT0EHs.png)

   ![S3 bucket details](https://i.imgur.com/UbsA5y3.png)

3. View the data within one of the files.
   
   ![S3 data](https://i.imgur.com/AmvOiO4.png)

4. Scroll to the bottom and click on `Run SQL query`.
   
   ![Run SQL query](https://i.imgur.com/wq7itJC.png)

5. Review the results of the data.
   
   ![SQL results](https://i.imgur.com/4iVEhac.png)

### Step 4: Create an Instance for Data Push
Attempt to create an instance of either `QueenMary` or `Titanic` to push data to the S3 bucket. For detailed steps on this, refer to the provided [Camel K Ship integration](configure-camel-k.md) documentation.

---

By following this tutorial, you should be able to view Kafka messages, integrate with AWS S3, and push data to an S3 bucket using the Data Lake project on OpenShift. Happy exploring!