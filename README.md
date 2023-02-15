# Amazon OpenSearch Service Monitor

This repository contains step by step demonstration to set up monitoring Stack for Amazon OpenSearch Service domains and Amazon OpenSearch Serverless collections across all specified regions. This example uses AWS CDK and Python.


## Table of Contents
1. [Context](#context)
2. [Prerequisites](#prerequisites)
3. [Deploy](#deploy)
4. [OpenSearch Subscription Filters](#cw-subscription-filters)
4. [Pre-built Monitoring Dashboards](#dashboards)
5. [Pre-built Alerts](#alerts)
6. [Clean up](#cleanup)
7. [Total Cost of Ownership](#tco)

## Context <a name="context"></a>
Amazon OpenSearch Service is a fully managed service that makes it easy for you to deploy, secure, and run OpenSearch cost effectively at scale. Customers often have an issue to manage and monitor multiple Amazon OpenSearch Service domains and OpenSearch Serverless collection as those metrics and logs are not available at centralized place for troubleshooting the issue. 
This example helps you to configure a monitoring for Amazon OpenSearch Service domains, and OpenSearch Serverless collections which will fetch the Cloudwatch Metrics and Cloudwatch logs from all domains/collections at a regular interval. This example also comes with pre-built OpenSearch dashboards and Alerts. 

## Architecture
![architecture](/images/amazon_opensearch_service_monitor_framework.png)

-----

## Prerequisites <a name="prerequisites"></a>

The following tools are required to deploy this Monitoring tool for Amazon OpenSearch Service.

AWS CDK - https://docs.aws.amazon.com/cdk/latest/guide/getting_started.html  
AWS CLI - https://aws.amazon.com/cli/  
Git -  https://git-scm.com/downloads  
nodejs - https://nodejs.org/en
python (3.6 or later) - https://www.python.org/downloads/  

### Create and deploy Amazon OpenSearch Service Monitor tool

Complete the following steps to set up the Amazon OpenSearch Service Monitor tool in your environment using CDK.

At a bash terminal session.

```bash
# clone the repo
$ git clone https://github.com/aws-samples/amazon-opensearch-service-monitor.git
# move to directory
$ cd amazon-opensearch-service-monitor
```

![Clone Repo](/images/opensearch_monitor_clone.png)

```bash
# bootstrap the remaining setup (assumes us-west-2)
# Enter the e-mail address for alert, as that will be used for sending the alert
# Alternatively you can change e-mail address manually in opensearch/opensearch_monitor_stack.py
$ bash bootstrap.sh
# activate the virtual environment
$ source .env/bin/activate
```

![Bootstrap](/images/opensearch_monitor_bootstrap.png)

### Bootstrap the CDK

Create the CDK configuration by bootstrapping the CDK (one-time activity for each region).

```bash
# bootstrap the cdk
(.env)$ cdk bootstrap aws://yourAccountID/yourRegion
```

![Terminal - Bootstrap the CDK](/images/opensearch_monitor_bootstrap_cdk.png)

-----

## Deploy <a name="deploy"></a>
Use the AWS CDK to deploy opensearch stack for Amazon OpenSearch Service. This stack comprises of creating/deploying below components:
1. Create VPC with 3 AZ
2. Create and launch Amazon OpenSearch Service cluster (version 2.3) having two t3.medium data nodes with 100GB of EBS storage volume. These 2 nodes are spread across 2 different AZ's
3. Create Dynamo DB table for timestamp tracking 
4. Create lambda function to fetch Cloudwatch metrics across all regions and all domains. By default it fetches the data every 5 min, which can be changed if needed. 
5. Create and launch an EC2 instance which acts as SSH tunnel to access dashboards, as all of our setup is secured and in VPC
6. Create default OpenSearch dashboards to visualize metrics across all domains and collections
7. Create and setup default e-mail alerts to newly launched Amazon OpenSearch Service cluster
8. Create Index template and Index State Management (ISM) policy to delete indices older than 366 days. (can be changed to different retention if needed)
9. Monitoring stack has an option to enable Ultra Warm (UW) which is disabled by default, Change settings [in this file](opensearch/opensearch_monitor_stack.py) to enable UW.
10. Create lambda function to fetch Cloudwatch metrics and Cloudwatch logs across all regions.


#### Note: Complete stack gets setup with pre-defined configuration defined in [opensearch_monitor_stack.py](opensearch/opensearch_monitor_stack.py), please review the settings such as e-mail, instance type, username, password before proceeding to deploy. You can also enable UW and dedicated master (if needed)

Run below command 
```bash
(.env)$ cdk deploy
```

The CDK will prompt to apply Security Changes, input "y" for Yes.

![Terminal - Deploy OpenSearch Monitor Tool](/images/opensearch_monitor_deploy.png)

  Once the app is deployed you will get the Dashboards URL, user and password to access OpenSearch Dashboards. Once logged in you can refer below sections to navigate around dashboards and alerts.

####  Note: After the stack is deployed you will recieve an e-mail to confirm the subscription, please confirm the same to start getting the alerts.  

-----

## Post-Deployment: Setup OpenSearch subscription filters for Cloudwatch logs <a name="cw-subscription-filters"></a>
  Once stack is deployed successfully you need to create subscription filter and assign them to Lambda. Run [setupCWSubscriptionFilter.py](opensearch/setupCWSubscriptionFilter.py) to create the subscription filter (assuming the CW log groups with prefix as /aws/aes/domains), if there is any change in prefix please make sure to change above file before running the steps as below.
    
```bash
(.env)$ python3 opensearch/setupCWSubscriptionFilter.py deploy
```
![Terminal - Setup CW Subscription filter Post Deploy](/images/opensearch_monitor_post_deploy.png)
-----

## Pre-built Monitoring Dashboards <a name="dashboards"></a>
  Monitoring domain comes with pre-built dashboards for OpenSearch Service and OpenSearch Serverless collection metrics, these dashboards can be accessed as below:
  1. Login to Dashboards: Access OpenSearch Dashboards with an IP obtained after the deployment and login as below
      ![Dashboards login screen](/images/opensearch_dashboards_login.png)

  2. Once logged in, select the private tenant from the pop up and then select dashboard as shown below
      ![OpenSearch Dashboards](/images/opensearch_dashboards_select.png)

  3. After clicking on dashboard, it displays list of the dashboard which comes as default
      ![OpenSearch Dashboards List](/images/opensearch_dashboards_list.png)

   - **Domain Metrics** : This gives a 360 degree view of all Amazon OpenSearch Service domains across the regions. 
      ![Domain Metrics At A glance](/images/opensearch_domain_metrics_at_a_glance.png)
   
   - **Domain Overview** :  This gives a more detailed metrics for a particular domain, could help to deep dive for issues into a specific domain. 
      ![Domain Overview](/images/opensearch_domain_overview.png)

   - **Serverless Collection Metrics** : This gives a 360 degree view of all Amazon OpenSearch Serverless collections across the regions.
     ![Domain Metrics At A glance](/images/opensearch_collection_metrics.png)

   - **Serverless Collection Overview** :  This gives a more detailed metrics for a particular collection, could help to deep dive for issues into a specific collection.
     ![Domain Overview](/images/opensearch_collection_overview.png)

-----

## Pre-built Alerts <a name="alerts"></a>

  Monitoring domains comes with pre-built alerts as below, which could help to get notified as an email alert for event such as Cluster Health, Disk Issue, Memory Issue , JVM issue etc.
These alerts are built for OpenSearch Service domains metrics. 
  
| Alert Type                    | Frequency     |
| ----------------------------- | ------------- |
| Cluster Health - Red          | 5 Min         |
| Cluster Index Writes Blocked  | 5 Min         |
| Automated Snapshot Failure    | 5 Min         |
| JVM Memory Pressure > 80%     | 5 Min         |
| CPU Utilization > 80%         | 15 Min        |
| No Kibana Healthy Nodes       | 15 Min        |
| No Dashboards Healthy Nodes   | 15 Min        |
| Invalid Host Header Requests  | 15 Min        |
| Cluster Health - Yellow       | 30 Min        |

-----
## Cleanup <a name=cleanup></a>

To clean up the stacks. destroy the opensearch stack, all other stacks will be torn down due to dependencies. 

```bash
(.env)$ cdk destroy
```

![Destroy](/images/opensearch_monitor_destroy.png)

To remove subscription for Cloudwatch logs run the script as below. This will traverse the Amazon OpenSearch Service cloudwatch logs and delete any filter which has been created during the deploy.

```bash
(.env)$ python3 opensearch/setupCWSubscriptionFilter.py destroy
```
![Terminal - Post Destroy](/images/opensearch_monitor_post_destroy.png)
-----
## Total Cost of Ownership <a name=tco></a>

Running this solution will incur charges of less than $10 per day for one domain with additional $2 per day for each additional domain.

-----
## Reporting Bugs

If you encounter a bug, please create a new issue with as much detail as possible and steps for reproducing the bug. See the [Contributing Guidelines](./CONTRIBUTING.md) for more details.

-----
## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

-----
## License

This library is licensed under the MIT-0 License. See the LICENSE file.
