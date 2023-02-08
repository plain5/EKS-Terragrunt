# ⏸️ Project scheme ⏸️
![](./project_scheme/image.jpg)

# ⚠️ Requirements ⚠️
* Before starting, you should install :

  - *[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)*
  - *[Terraform](https://developer.hashicorp.com/terraform/downloads)*
  - *[Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)*
  - *[kubectl](https://kubernetes.io/docs/tasks/tools/)*
  - *[Helm](https://helm.sh/docs/intro/install/)*
  - *[Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)*

# ⚙️ Additional configuration ⚙️
* Before starting, you should perform the following actions :
 
  * create IAM user with `AdministratorAccess`;
  * edit `~/.aws/credentials` file like showed below :<br>
    *[default]<br>
    aws_access_key_id = ACCESS_KEY_FROM_THE_FIRST_STEP<br>
    aws_secret_access_key = SECRET_ACCESS_KEY_FROM_THE_FIRST_STEP<br>*
  * change S3 Bucket config in the root `terragrunt.hcl`;
  * set up your credentials for OpenSearch Service `master user` in `infrastructure/opensearch/terragrunt.hcl`;
  * replace `YOUR_AWS_ACCOUNT_ID` with your value in :
    * `infrastructure/opensearch_module/main.tf`;
    * `ansible/roles/build-push-to-ecr/tasks/main.yml`;
    * `ansible/roles/upgrade_release/tasks/main.yml`.
  * don't forget to change `ingress.sslCertificateARN` & `efsId` in `ansible/Node_App_Chart/values.yaml` after infrastructure provisioning.

# 🏰 Create infrastructure 🏰
* Perform the following steps :
```
cd infrastructure/
```
```
terragrunt run-all plan
```
```
terragrunt run-all apply
```
  *I can't but mention that infrastructure creation takes at least 70 minutes.*<br>
  *Keep in mind that it's `not free` to provision and hold this infrastructure. You'll be charged according to the AWS pricing model.*
  
# 🧊 Update kubeconfig 🧊
* After infrastructure provisioning, run :
```
aws eks update-kubeconfig --region us-east-1 --name education-eks
```

# 🧱 Prepare your EKS cluster 🧱
* Install the following :

  - *[AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html#lbc-install-controller)*
  - *[Amazon EFS CSI driver](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html)*
  - *[Secrets Store CSI Secret driver and AWS Secrets and Configuration Provider (ASCP)](https://www.eksworkshop.com/beginner/194_secrets_manager/configure-csi-driver/)*

# ㊙️ Create Secrets Manager secret ㊙️
* Create only `one` Secrets Manager secret :

  * for `Secret type` choose `Other type of secret`;
  * create 3 `Key/value pairs` with the following keys : `CONTENTFUL_SPACE_ID`, `CONTENTFUL_DELIVERY_TOKEN`, `CONTENTFUL_PREVIEW_TOKEN`. Fill in the values yourself 😉
  * give `prod/app/variables` value for the secret name.

# 📑 Prepare needed IAM Roles 📑
  1) Create IAM Policy with access to your Secrets Manager secret (replace `YOUR_SECRET_ARN` with your Secrets Manager secret ARN) :
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": "YOUR_SECRET_ARN"
        }
    ]
}
```

  2) Create IAM Role for access with our ServiceAccount to the Secrets Manager :
  
     * for `Identity provider` choose one available `OpenID Connect` which was automatically created during infrastructure provisioning;
     * for `Audience` choose `sts.amazonaws.com`;
     * for `Permission policies` choose our policy from the first step;
     * create your role. After this, edit its `Trust Relationship` like below (replace `YOUR_AWS_ACCOUNT_ID` and `YOUR_EKS_CLUSTER_ID` with appropriate values) :
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/YOUR_EKS_CLUSTER_ID"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.us-east-1.amazonaws.com/id/YOUR_EKS_CLUSTER_ID:sub": "system:serviceaccount:application:app"
                }
            }
        }
    ]
}
```

  3) Move to `ansible/Node_App_Chart/values.yaml` and change `ServiceAccount.roleARN` value with Role ARN from the previous step.

  4) Create IAM Role for future work with OpenSearch Service :
  
     * choose `Trusted entity type` - `AWS service`, `Use case` - `Lambda`;
     * for `Permission policies` choose AWS managed `AWSLambdaBasicExecutionRole` & `AmazonOpenSearchServiceFullAccess`.
  
# 🐳 Prepare Docker image 🐳
* Before starting, you should move `ansible/` directory to the `$HOME` destination. It's necessary! The next steps :

```
cd ~/ansible/
```
```
ansible-playbook build-push-to-ecr.yml
```

After these steps, navigate to your AWS ECR repository and copy URI of just pushed image. Then move to `~/ansible/Node_App_Chart/values.yaml` and change the `container.image` value by just copied. This only needs to be done once. Afterward, another Ansible role will be responsible for this.
  
# 🚀 Deploy your application 🚀
* Perform the following steps :
```
cd ~/ansible/
```
```
ansible-playbook deploy_application.yaml
```
```
for the release name enter *application* (without asterisks)
```

Now you can check results using `helm list -A` command!

# 5️⃣3️⃣ Create a record for your ALB endpoint 5️⃣3️⃣
* Perform the following :
  * replace Route 53 `zone_name` value with yours in `infrastructure/common_vars.hcl`;
  * uncomment `infrastructure/route53_record/terragrunt.hcl`;
  * run `kubectl get ingress -n application`. Copy value of the `ADDRESS` field;
  * navigate to `infrastructure/common_vars.hcl` and change `elb_dns_name` value by just copied;
```
cd infrastructure/
```
```
terragrunt run-all plan
```
```
terragrunt run-all apply
```

# 🔍 Enable CloudWatch Container Insights 🔎
* Perform the following :

```
mkdir cloudwatch_fluentbit && cd cloudwatch_fluentbit
```
```
ClusterName=education-eks
RegionName=us-east-1
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${RegionName}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl apply -f -
```
```
curl -O https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-configmap.yaml
```
```
in line 11, change the variable so it points to your cluster : "cluster_name": "{{education-eks}}",
```
```
kubectl apply -f cwagent-configmap.yaml
```
```
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-daemonset.yaml
```

* Check your results :

```
kubectl get pods -n amazon-cloudwatch
```
```
kubectl logs <POD_NAME>  -n amazon-cloudwatch
```

* Full list of CloudWatch Log groups will look like :

  * /aws/containerinsights/education-eks/application;
  * /aws/containerinsights/education-eks/dataplane;
  * /aws/containerinsights/education-eks/host;
  * /aws/containerinsights/education-eks/performance;
  * /aws/eks/education-eks/cluster.
  
# 🗺️ OpenSearch Service 🗺️
  1) Navigate to OpenSearch Service in the  AWS Management Console : 

      * Click on `its-application` cluster -> open `OpenSearch Dashboards URL`;
      * Log in with credentials provided at `infrastructure/opensearch/terragrunt.hcl`;
      * `Explore on my own` -> `Select your tenant` - `Global` -> `Confirm`;
      * click on the three vertical lines in the left upper corner -> `Security` -> `Roles` -> `all_access` -> `Mapped users`;
      * click on `Manage mapping` button -> for `Backend roles` put IAM Role ARN created in the `Prepare needed IAM Roles` block step №4 -> `Map`.

  2) We also need to enable CloudWatch Logs streaming for `application logs` to the OpenSeacrh Service. Move to CloudWatch -> Log groups. Then :

      * select `/aws/containerinsights/education-eks/application` Log group;
      * click `Actions` -> `Subscription filters` -> `Create Amazon OpenSearch Service subscription filter`; you'll be forwarded on a new page;
      * `Select account` - `This account`, `Amazon Opensearch Service Cluser` - choose one available `its-application`, `Lambda IAM Execution Role` select created in the `Prepare needed IAM Roles` block step №4;
      * `Log format` - `Json`, `Subscription filter pattern` - `" "`, `Subscription filter name` enter what you wish. Scroll down and click `Start Streaming`.

  3) The last step is to create `Index pattern` in OpenSearch Service :
      * open `OpenSearch Dashboards URL` main page;
      * click on the three vertical lines in the left upper corner -> `Discover` -> `Index patterns` -> `Create index pattern`;
      * put `cwl*` for `Index pattern name` (below that field, you'll see matched index with your logs named `cwl-*`) -> click `Next step`;
      * choose `@timestamp` for `Time field` -> `Create index pattern`;
      * click on the three vertical lines in the left upper corner -> `Discover` -> that's all. Now you are accessible to dive deep into the given data!

  4) You can enable as many log streams as you wish. Select another `Log group` and perform the written in steps №2 & №3 actions. You'll only need to specify a new `Index pattern name` in the step №3.

# 🛠️ How to update infrastructure? 🛠️
* For example, the application folder got new changes. It's time to build a new Docker image : 
```
cd ~/ansible/
```
```
ansible-playbook build-push-to-ecr.yml
```
  OK, the image is successfully pushed to ECR. What's next? It's time to update K8s :
```
cd ~/ansible/
```
```
ansible-playbook upgrade_release.yaml
```
```
for the release name enter *application* (without asterisks)
```

# 🧹 Cleanup 🧹
* If you want to remove K8s objects, perform the following :

```
helm uninstall application -n application
```
```
kubectl delete -f ~/ansible/namespace/namespace.yaml
```

* If you want to delete AWS infrastructure, perform the following :

  * delete all Docker images in the ECR repository;
  * delete all `Subscription filters` in the CloudWatch `Log groups`;
  * delete all Lambda functiosn created by `Subscription filters`;
  * delete all Lambda functions `Log groups` in CloudWatch;
  * disable CLoudWatch Container Insights :
```
ClusterName=education-eks
RegionName=us-east-1
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${RegionName}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl delete -f -
```
```
delete four CLoudWatch Container Insights Log groups;
```
```
cd infrastructure/
```
```
terragrunt run-all destroy
```
Have you made it this far? I have the utmost respect for you 👏</br>
glhf.
