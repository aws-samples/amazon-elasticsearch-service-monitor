# Amazon Elasticsearch Service Monitor

This repository contains step by step demonstration to setup monitoring Stack for Amazon ES domains across all specified regions. This example uses AWS CDK and Python.


## Table of Contents
1. [Context](#context)
2. [Prerequisites](#prerequisites)
3. [Deploy](#deploy)
4. [Pre-built Monitoring Dashboards](#dashboards)
5. [Pre-built Alerts](#alerts)
6. [Clean up](#cleanup)
7. [Total Cost of Ownership](#tco)

## Context <a name="context"></a>
Amazon Elasticsearch Service is a fully managed service that makes it easy for you to deploy, secure, and run Elasticsearch cost effectively at scale. Customers often have an issue to manage and monitor multiple Amazon ES domains as those metrics are not available at centralized place for troubleshooting the issue. 
This example helps you to configure a monitoring Amazon ES domains, which will fetch the Cloudwatch Metrics from all other domains at a regular interval. This example also comes with pre-built Kibana dashboards and Alerts. 

## Architecture
![architecture](/images/Amazon_ES_Monitoring_Framework.png)

-----

## Prerequisites <a name="prerequisites"></a>

The following tools are required to deploy this CDK Monitoring tool for Amazon ES.

AWS CDK - https://docs.aws.amazon.com/cdk/latest/guide/getting_started.html  
AWS CLI - https://aws.amazon.com/cli/  
Git -  https://git-scm.com/downloads  
nodejs - https://nodejs.org/en
python (3.6 or later) - https://www.python.org/downloads/  

### Create and deploy CDK Monitoring tool

Complete the following steps to set up the CDK Monitoring tool in your environment.

At a bash terminal session.

```bash
# clone the repo
$ git clone https://github.com/aws-samples/amazon-elasticsearch-service-monitor.git
# move to directory
$ cd amazon-elasticsearch-service-monitor
```

![Clone Repo](/images/cdk_monitoring_clone.png)

```bash
# bootstrap the remaining setup (assumes us-west-2)
# Enter the e-mail address for alert, as that will be used for sending the alert
# Alternatively you can change e-mail address manually in monitoring_cdk/monitoring_cdk_stack.py
$ bash bootstrap.sh
# activate the virtual environment
$ source .env/bin/activate
```

![Bootstrap](/images/cdk_monitoring_bootstrap.png)

### Bootstrap the CDK

Create the CDK configuration by bootstrapping the CDK.

```bash
# bootstrap the cdk
(.env)$ cdk bootstrap aws://yourAccountID/yourRegion
```

![Terminal - Bootstrap the CDK](/images/cdk_monitoring_bootstrap_cdk.png)

-----

## Deploy <a name="deploy"></a>
Use the AWS CDK to deploy monitoring-cdk stack for Amazon ES. This stack comprises of creating/deploying below components:
1. Create VPC with 3 AZ
2. Create and launch Amazon ES cluster (version 7.10) having two t3.medium data nodes with 100GB of EBS storage volume. These 2 nodes are spread across 2 different AZ's
3. Create Dynamo DB table for timestamp tracking 
4. Create lambda function to fetch Cloudwatch metrics across all regions and all domains. By default it fetches the data every 5 min, which can be changed if needed. 
5. Create and launch an EC2 instance which acts as SSH tunnel to access kibana, as all of our setup is secured and in VPC
6. Create default kibana dashboard to visualize metrics across all domains
7. Create and setup default e-mail alerts to newly launched Amazon ES cluster
8. Create Index template and Index State Management (ISM) policy to delete indices older than 366 days. (can be changed to different retention if needed)
9. Monitoring stack has an option to enable Ultra Warm (UW) which is disabled by default, Change settings [in this file](monitoring_cdk/monitoring_cdk_stack.py) to enable UW.


#### Note: Complete stack gets setup with pre-defined configuration defined in [monitoring_cdk_stack.py](monitoring_cdk/monitoring_cdk_stack.py), please review the settings such as e-mail, instance type, username, password before proceeding to deploy. You can also enable UW and dedicated master (if needed)

Run below command 
```bash
(.env)$ cdk deploy
```

The CDK will prompt to apply Security Changes, input "y" for Yes.

![Terminal - Deploy CDK](/images/cdk_monitoring_deploy.png)

  Once the app is deployed you will get the Kibana URL, user and password to access Kibana. Once logged in you can refer below sections to navigate around dashboards and alerts.

####  Note: After the stack is deployed you will recieve an e-mail to confirm the subscription, please confirm the same to start getting the alerts.  

-----

## Pre-built Monitoring Dashboards <a name="dashboards"></a>
  Monitoring CDK comes with pre-built dashboards which can be accessed as below:
  1. Login to Kibana: Access kibana with an IP obtained after the deployment and login as below
      ![Kibana login screen](/images/kibana_login.png)

  2. Once logged in, select dashboard as shown below
      ![Kibana dashboard](/images/kibana_select_dashboard.png)

  3. After clicking on dashboard, it displays list of the dashboard which comes as default
      ![Kibana dashboard List](/images/kibana_dashboards_list.png)

   - **Domain Metrics At A glance** : This gives a 360 degree view of all Amazon ES domains across the regions. 
      ![Domain Metrics At A glance](/images/dashboard_domain_metrics_at_a_glance.png)
   
   - **Domain Overview** :  This gives a more detailed metrics for a particular domain, could help to deep dive for issues into a specific domain. 
      ![Domain Overview](/images/dashboard_domain_overview.png)

-----

## Pre-built Alerts <a name="alerts"></a>

  Monioring CDK comes with pre-built alerts as below, which could help to get notified as an email alert for event such as Cluster Health, Disk Issue, Memory Issue , JVM issue etc. 
  
| Alert Type                    | Frequency     |
| ----------------------------- | ------------- |
| Cluster Health - Red          | 5 Min         |
| Cluster Index Writes Blocked  | 5 Min         |
| Automated Snapshot Failure    | 5 Min         |
| JVM Memory Pressure > 80%     | 5 Min         |
| CPU Utilization > 80%         | 15 Min        |
| No Kibana Healthy Nodes       | 15 Min        |
| Invalid Host Header Requests  | 15 Min        |
| Cluster Health - Yellow       | 30 Min        |

-----
## Cleanup <a name=cleanup></a>

To clean up the stacks... destroy the monitoring-cdk stack, all other stacks will be torn down due to dependencies. 

CloudWatch logs will need to be separately removed.

```bash
(.env)$ cdk destroy
```

![Destroy](/images/cdk_monitoring_destroy.png)

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
