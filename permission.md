# Assign AWS IAM Permissions for MATLAB Users on Linux

AWS® administrators can grant the least privileged permissions to end users to deploy MATLAB® on a Linux® instance in AWS. If you are an end user, contact your AWS administrator to grant you the necessary permissions.

AWS administrators can choose between two permission levels for their users:

* *Full Stack Creation workflow*: Users can create the entire stack. This approach is recommended for streamlined setups.
* *Pass Role Workflow*: Users can only create non-IAM resources in their stack. AWS admins must create necessary IAM roles that the user must pass to the stack. This approach is suitable for tighter control over IAM policies.

For both options, see the [Quick Start using AWS CloudFormation template](#quick-start-using-aws-cloudformation-template) section to automatically generate the necessary IAM policies. If you want further configuration of the IAM policies, see [Customize IAM policies](#customize-iam-policies) section.

## Quick Start using AWS CloudFormation template

Using the CloudFormation template below is recommended for most use cases, as it automatically creates and configures your AWS account to grant the necessary permissions to your users.

1. Deploy the Permission CloudFormation template.<br>
    Click the "Launch Stack" button to open the CloudFormation console, fill out the template parameters, and create the stack. You must be logged in to your AWS account before clicking the button below.<br><br>

   [![Deploy Reference Architecture Permission Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?#/stacks/create/review?templateURL=https://mathworks-reference-architectures-templates.s3.us-east-1.amazonaws.com/permissions-template/v1/0/0/permissions-template.json)<br>

    <details> <summary>CloudFormation template parameters</summary> <table><thead><tr><th>Parameter Label</th><th>Description</th></tr></thead><tbody>

    <tr><td>Enable MATLAB deployment</td><td>Select yes to allow your users to deploy MATLAB. <br><br> <strong>Note: </strong>You might see other MathWorks' cloud products in the CloudFormation console, and if you want, you can enable those for your users as well.</td></tr>

    <tr><td>User permission level</td><td>Choose 'Full Stack Creation' or 'Pass Role' workflows. 'Full Stack Creation' allows users to create the entire stack, including IAM roles, while following the principle of least privilege. Recommended for streamlined setups. 'Pass Role Workflow' limits users to resource creation only. Suitable for tighter control over IAM roles and permissions.</td></tr>

    <tr><td>AWS Region restriction</td><td>Allowed AWS Region to deploy resources. Select '*' for all regions.</td></tr>

    <tr><td>Resource naming prefix</td><td>Prefix to restrict users to create CloudFormation stacks or resources with names starting with this value. Use up to 10 lowercase letters or hyphens. Useful for isolating resources by team (for example, 'engr-', 'mrkt-').</td></tr>

    <tr><td>Additional IAM policies for Common Execution Role</td><td>(Optional) Specify up to five valid IAM policy ARNs (AWS-managed or customer-managed) to grant additional permissions to your users' EC2 instances. These policies must have a path equal to '/MW/' and a name starting with the value in 'Resource Naming Prefix'. Applicable only when you configure 'User Permission Level' to 'Pass Role Workflow'. Users with 'Full Stack Creation' permissions can directly pass IAM policy ARNs during stack deployment.</td></tr>

    <tr><td>IAM role names</td><td>(Optional) Comma-separated list of existing IAM roles to extend permissions to. For example, specify existing IAM roles assumed by users to extend their permissions to allow users to deploy MathWorks' Reference Architecture.</td></tr>

    <tr><td>IAM group names</td><td>(Optional) Comma-separated list of existing IAM groups to extend permissions to. Applies to all members in these groups.</td></tr>

    <tr><td>IAM user names</td><td>(Optional) Comma-separated list of existing IAM users to extend permissions to.</td></tr>

    <tr><td>AWS principal ARN</td><td>(Optional) Specify an AWS principal ARN to assume the IAM role created by this stack. If your AWS Principal is not supported by this template, you can temporarily use '*'. In this case, after deployment, update the IAM role's trust relationship to your custom AWS Principal in the IAM Console.</td></tr>

    <tr><td>AWS principal external ID</td><td>(Optional) A unique identifier to allow third-party access to your AWS resources. This ensures that only trusted parties can assume roles in your account. For more information, see https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_common-scenarios_third-party.html.</td></tr>

    <tr><td>SAML federated identity provider ARN</td><td>(Optional) Specify the SAML Federated Identity Provider ARN to assume the provisioning role. If specified, you must also provide the 'SAML audience URL' parameter. Leave blank if you are not using SAML federation for user authentication.</td></tr>

    <tr><td>SAML audience URL</td><td>(Optional) If specified, you must also provide the 'SAMLFederatedIdentityProvider'. Leave blank if you are not using SAML federation for user authentication.</td></tr>

    </tbody></table> </details><br>

    (Optional) CloudFormation parameters offer sufficient flexibility for most use cases, allowing you to attach the generated policies to existing IAM users, groups, or roles, or to associate them with a new IAM role. However, for advanced setup cases, you can [update the IAM role's trust policy in AWS Console](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_update-role-trust-policy.html).

2. Inform your users about the following:

    * Users must ensure that the name of their stacks begins with the *Resource Naming Prefix* that you define in the template. Failure to do so will result in stack creation errors.

    * If you selected the "Pass Role Workflow" option for the user permission level, the CloudFormation template will create an IAM role, which your users must pass its name to "CustomIamRole" parameter when deploying their MATLAB stack. You can find its value in the CloudFormation output tab in AWS console as "CommonExecutionRoleName" output.

## Customize IAM policies

This section provides IAM policy JSONs for advanced use cases, enabling you to create custom IAM policies as an alternative to the managed policies offered by the CloudFormation template. Following this section gives you more control over the permissions but requires more effort and knowledge of AWS IAM. This section can also allow you to gain a clearer understanding of the permissions created by the CloudFormation template.

> <h3>Terminology & Definitions</h3> Before you continue, ensure that you are familiar with these terms.<br><details><summary><strong>Types of IAM Policies</strong></summary><ul><li><strong>Provisioning policy</strong>: A wrapper for permissions needed to create MATLAB deployment resources in the AWS account. Attaching this policy to an IAM user or role will allow them to deploy MATLAB CloudFormation template and its resources.</li><li><strong>Execution policy</strong>: Permissions required by AWS services (e.g., EC2 or Lambda functions) to execute automated workloads, such as pushing logs from an EC2 instance to CloudWatch. This policy is attached to the IAM role assumed by the EC2 instance or Lambda function.</li></ul></details><details><summary><strong>User Permission Levels</strong></summary>AWS administrators can choose between two permission levels for their users.<ul><li><em>Full Stack Creation</em>: This option is recommended for most users due to its streamlined setup process. Users can deploy the entire CloudFormation stack but cannot create additional IAM resources directly. However, the user's stack can create the necessary IAM resources required for deploying MATLAB on AWS.</li><li><em>Pass Role Workflow</em>: This option is suitable for organizations that require stricter control over IAM role creation and permissions. In this workflow, users can only create the necessary resources. The account administrator creates IAM roles to be attached to AWS resources, such as EC2 instances.</li></ul></details><details><summary><b>Trade-offs to consider when choosing between user permission levels</b></summary><p>Selecting the appropriate permission level for your users is important. While both options adhere to the principle of least privileged access, you must consider these trade-offs.</p><table><thead><tr><th>Description</th><th>Full Stack Creation workflow</th><th>Pass Role Workflow</th></tr></thead><tbody><tr><td>High-level responsibilities for admin and user</td><td><ul><li><strong>IAM Administrator:</strong><br>Lower admin involvement. Admin sets up the user role.<br><br></li><li><strong>Reference Architecture User:</strong><br>User deploys the stack.</li></ul></td><td><ul><li><strong>IAM Administrator:</strong><br>Higher admin involvement. Admin sets up the user role.<br>Admin also creates an execution IAM Role and shares its name with the user.<br><br></li><li><strong>Reference Architecture User:</strong><br>User passes the execution IAM Role name to CloudFormation template.<br>User deploys the stack.</li></ul></td></tr><tr><td>Ability to create new IAM Roles</td><td>Users cannot create IAM roles. However, users' stacks can create new IAM roles as required by the reference architecture template. <br><br><strong>Note:</strong> The default IAM policy provided below limits users to create IAM roles only when the CloudFormation template is hosted in MathWorks' approved S3 bucket.<br><br></td><td>Neither users nor their stacks can create IAM roles. Admin needs to create the IAM roles for EC2 instances, Lambda functions, and other AWS services. You can find the <code>Common Execution Role</code> below that you can use for all the services. <br><br><strong>Note:</strong> Even though the <code>Common Execution Role</code> has restricted permissions, it allows different stacks to use the same IAM role and interact with each other's resources. For stricter isolation, create separate IAM roles for each user/stack.</td></tr><tr><td>Additional permissions</td><td>Users can attach additional IAM policies to their EC2 instances when deploying their MATLAB CloudFormation template.<br><br><strong>Note:</strong> These IAM policies must have a path of <code>/MW/</code> and have a name that starts with the value specified as the <code>Resource Naming Prefix</code>, as detailed below. This allows account administrators to control the permissions that can be assigned to different user stacks and EC2 instances.</td><td>Users cannot attach additional IAM policies to their stacks and EC2 instances. Any additional permissions must be pre-configured by the AWS account administrator. For details, refer to the "Additional IAM Policies for Common Execution Role" CloudFormation parameter.</td></tr></tbody></table></details><details><summary><strong>Placeholders in IAM Policy JSONs</strong></summary><p>The JSON policies below contain placeholders denoted by <code>&lt;&lt;</code> and <code>&gt;&gt;</code>. This table explains each placeholder. If you are using these JSONs to create IAM policies, you must replace the placeholders with the appropriate values.</p><table><thead><tr><th>Placeholder</th><th>Description</th></tr></thead><tbody><tr><td><code>&lt;&lt;AWS_REGION&gt;&gt;</code></td><td>AWS Region to limit your users for resource deployment. It can be a specific <a href="https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions">AWS Region</a> or <code>*</code> for all regions.</td></tr><tr><td><code>&lt;&lt;AWS_ACCOUNT_ID&gt;&gt;</code></td><td>Your AWS account ID, a 12-digit number.</td></tr><tr><td><code>&lt;&lt;AWS_PARTITION&gt;&gt;</code></td><td>For standard AWS Regions, the partition is <code>aws</code>. For other partitions, it is "aws-partitionname". See AWS documentation on <a href="https://docs.aws.amazon.com/whitepapers/latest/aws-fault-isolation-boundaries/partitions.html">Partitions</a>.</td></tr><tr><td><code>&lt;&lt;AWS_URL_SUFFIX&gt;&gt;</code></td><td>Typically <code>amazonaws.com</code>, but may differ by Region. For example, the suffix for China (Beijing) Region is <code>amazonaws.com.cn</code>.</td></tr><tr><td><code>&lt;&lt;RESOURCE_NAMING_PREFIX&gt;&gt;</code></td><td>Prefix for users to create CloudFormation stacks or resources. Must be ≤10 characters, containing only lowercase letters and hyphens. Used to manage resources by different teams independently.</td></tr></tbody></table></details>

### IAM Policy for Full Stack Creation Workflow

Below IAM Policy allows users to create the entire stack, including IAM roles required in the CloudFormation template. Users can attach additional existing IAM policies to their EC2 instances if these policies use the path '/MW/' and the policy name starts with the 'Resource naming prefix' that you specify in the JSON policy.

<details>

<summary>Provisioning IAM Policy (allows full stack creation)</summary>

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CloudFormationCreate",
            "Effect": "Allow",
            "Action": [
                "cloudformation:CreateStack"
            ],
            "Resource": [
                "arn:<<AWS_PARTITION>>:cloudformation:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:stack/<<RESOURCE_NAMING_PREFIX>>*"
            ],
            "Condition": {
                "StringLike": {
                    "cloudformation:TemplateUrl": [
                        "https://mathworks-reference-architectures-templates.s3.amazonaws.com/*",
                        "https://matlab-on-aws.s3.amazonaws.com/*"
                    ]
                }
            }
        },
        {
            "Sid": "CloudformationActionsFromCloudFormation",
            "Effect": "Allow",
            "Action": [
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStackEvents",
                "cloudformation:DescribeStacks"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:cloudformation:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:stack/<<RESOURCE_NAMING_PREFIX>>*"
        },
        {
            "Sid": "CloudformationActionsFromCloudFormation2",
            "Effect": "Allow",
            "Action": [
                "cloudformation:*ChangeSet*",
                "cloudformation:GetStackPolicy",
                "cloudformation:GetTemplate",
                "cloudformation:GetTemplateSummary",
                "cloudformation:ListStackResources"
            ],
            "Resource": [
                "arn:<<AWS_PARTITION>>:cloudformation:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:stack/<<RESOURCE_NAMING_PREFIX>>*",
                "arn:<<AWS_PARTITION>>:cloudformation:<<AWS_REGION>>:aws:transform/*"
            ]
        },
        {
            "Sid": "MultipleServicesActionsFromCloudFormation",
            "Effect": "Allow",
            "Action": [
                "ec2:AllocateAddress",
                "ec2:AssociateAddress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteSecurityGroup",
                "ec2:DescribeAddresses",
                "ec2:DescribeInstanceAttribute",
                "ec2:DescribeInstanceCreditSpecifications",
                "ec2:DescribeInstances",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSecurityGroupRules",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:DescribeVpcs",
                "ec2:DisassociateAddress",
                "ec2:ReleaseAddress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "logs:DescribeLogGroups",
                "logs:ListTagsForResource",
                "ssm:ListAssociations",
                "ssm:ListTagsForResource"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "EventsActionsFromCloudFormation",
            "Effect": "Allow",
            "Action": [
                "events:DeleteRule",
                "events:DescribeRule",
                "events:ListTargetsByRule",
                "events:PutRule",
                "events:PutTargets",
                "events:RemoveTargets"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:events:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:rule/<<RESOURCE_NAMING_PREFIX>>*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "IamActionsFromCloudFormation",
            "Effect": "Allow",
            "Action": [
                "iam:AttachRolePolicy",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:DeleteRolePolicy",
                "iam:DetachRolePolicy",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "iam:ListAttachedRolePolicies",
                "iam:ListRolePolicies",
                "iam:PassRole",
                "iam:PutRolePolicy",
                "iam:TagRole"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:iam::<<AWS_ACCOUNT_ID>>:role/MW/<<RESOURCE_NAMING_PREFIX>>*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "IamActionsFromCloudFormation2",
            "Effect": "Allow",
            "Action": [
                "iam:AddRoleToInstanceProfile",
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:GetInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:iam::<<AWS_ACCOUNT_ID>>:instance-profile/MW/<<RESOURCE_NAMING_PREFIX>>*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "LambdaActionsFromCloudFormation",
            "Effect": "Allow",
            "Action": [
                "lambda:AddPermission",
                "lambda:CreateFunction",
                "lambda:DeleteFunction",
                "lambda:GetFunction",
                "lambda:GetFunctionCodeSigningConfig",
                "lambda:GetFunctionRecursionConfig",
                "lambda:GetPolicy",
                "lambda:GetRuntimeManagementConfig",
                "lambda:InvokeFunction",
                "lambda:RemovePermission",
                "lambda:TagResource"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:lambda:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:function:<<RESOURCE_NAMING_PREFIX>>*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "LogsActionsFromCloudFormation",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:DeleteLogGroup"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:logs:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:log-group:<<RESOURCE_NAMING_PREFIX>>*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "LogsActionsFromCloudFormation2",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:DeleteLogGroup",
                "logs:PutRetentionPolicy"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:logs:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:log-group:/aws/lambda/<<RESOURCE_NAMING_PREFIX>>*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "SsmActionsFromCloudFormation",
            "Effect": "Allow",
            "Action": [
                "ssm:AddTagsToResource",
                "ssm:CreateDocument",
                "ssm:DeleteDocument",
                "ssm:DescribeDocument",
                "ssm:GetDocument"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:ssm:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:document/<<RESOURCE_NAMING_PREFIX>>*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "EC2StopStart",
            "Effect": "Allow",
            "Action": [
                "ec2:StartInstances",
                "ec2:StopInstances"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:ec2:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:instance/*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/mw-ProductID": "MathWorks-MATLAB-Linux"
                },
                "StringLike": {
                    "aws:ResourceTag/mw-StackName": "<<RESOURCE_NAMING_PREFIX>>*"
                }
            }
        },
        {
            "Sid": "ReadOnlyActionsForSmoothConsoleExperience",
            "Effect": "Allow",
            "Action": [
                "cloudformation:GetTemplateSummary",
                "cloudformation:ListStacks",
                "ec2:DescribeInstances",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "logs:DescribeLogGroups",
                "ssm:DescribeInstanceInformation",
                "ssm:GetConnectionStatus"
            ],
            "Resource": "*"
        },
        {
            "Sid": "EC2KeyPairWriteAccess",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateKeyPair",
                "ec2:DeleteKeyPair"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:ec2:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:key-pair/<<RESOURCE_NAMING_PREFIX>>*"
        },
        {
            "Sid": "CloudWatchLogsReadOnlyAccess",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogStreams",
                "logs:GetLogEvents"
            ],
            "Resource": [
                "arn:<<AWS_PARTITION>>:logs:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:log-group:/aws/lambda/<<RESOURCE_NAMING_PREFIX>>*",
                "arn:<<AWS_PARTITION>>:logs:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:log-group:<<RESOURCE_NAMING_PREFIX>>*"
            ]
        }
    ]
}
```

</details>

### IAM Policies for Pass Role Workflow

This workflow restricts users from creating IAM roles. Instead, you create a common IAM execution role, and the user must pass the name of the role to the stack during deployment. You can use the provisioning policy below to allow users to deploy the stack without creating IAM roles. This policy is similar to the one in the "Full Stack Creation Workflow" section but excludes any write permissions in the IAM service.

<details>

<summary>Provisioning IAM Policy (doesn't allow IAM resource creation in your users' stacks)</summary>

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CloudFormationCreate",
            "Effect": "Allow",
            "Action": [
                "cloudformation:CreateStack"
            ],
            "Resource": [
                "arn:<<AWS_PARTITION>>:cloudformation:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:stack/<<RESOURCE_NAMING_PREFIX>>*"
            ],
            "Condition": {
                "StringLike": {
                    "cloudformation:TemplateUrl": [
                        "https://mathworks-reference-architectures-templates.s3.amazonaws.com/*",
                        "https://matlab-on-aws.s3.amazonaws.com/*"
                    ]
                }
            }
        },
        {
            "Sid": "CloudformationActionsFromCloudFormation",
            "Effect": "Allow",
            "Action": [
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStackEvents",
                "cloudformation:DescribeStacks"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:cloudformation:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:stack/<<RESOURCE_NAMING_PREFIX>>*"
        },
        {
            "Sid": "CloudformationActionsFromCloudFormation2",
            "Effect": "Allow",
            "Action": [
                "cloudformation:*ChangeSet*",
                "cloudformation:GetStackPolicy",
                "cloudformation:GetTemplate",
                "cloudformation:GetTemplateSummary",
                "cloudformation:ListStackResources"
            ],
            "Resource": [
                "arn:<<AWS_PARTITION>>:cloudformation:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:stack/<<RESOURCE_NAMING_PREFIX>>*",
                "arn:<<AWS_PARTITION>>:cloudformation:<<AWS_REGION>>:aws:transform/*"
            ]
        },
        {
            "Sid": "MultipleServicesActionsFromCloudFormation",
            "Effect": "Allow",
            "Action": [
                "ec2:AllocateAddress",
                "ec2:AssociateAddress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteSecurityGroup",
                "ec2:DescribeAddresses",
                "ec2:DescribeInstanceAttribute",
                "ec2:DescribeInstanceCreditSpecifications",
                "ec2:DescribeInstances",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSecurityGroupRules",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:DescribeVpcs",
                "ec2:DisassociateAddress",
                "ec2:ReleaseAddress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "logs:DescribeLogGroups",
                "logs:ListTagsForResource",
                "ssm:ListAssociations",
                "ssm:ListTagsForResource"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "EventsActionsFromCloudFormation",
            "Effect": "Allow",
            "Action": [
                "events:DeleteRule",
                "events:DescribeRule",
                "events:ListTargetsByRule",
                "events:PutRule",
                "events:PutTargets",
                "events:RemoveTargets"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:events:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:rule/<<RESOURCE_NAMING_PREFIX>>*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "IamActionsFromCloudFormation",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:GetRolePolicy",
                "iam:ListAttachedRolePolicies",
                "iam:ListRolePolicies",
                "iam:PassRole"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:iam::<<AWS_ACCOUNT_ID>>:role/MW/<<RESOURCE_NAMING_PREFIX>>*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "IamActionsFromCloudFormation2",
            "Effect": "Allow",
            "Action": [
                "iam:AddRoleToInstanceProfile",
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:GetInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:iam::<<AWS_ACCOUNT_ID>>:instance-profile/MW/<<RESOURCE_NAMING_PREFIX>>*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "LambdaActionsFromCloudFormation",
            "Effect": "Allow",
            "Action": [
                "lambda:AddPermission",
                "lambda:CreateFunction",
                "lambda:DeleteFunction",
                "lambda:GetFunction",
                "lambda:GetFunctionCodeSigningConfig",
                "lambda:GetFunctionRecursionConfig",
                "lambda:GetPolicy",
                "lambda:GetRuntimeManagementConfig",
                "lambda:InvokeFunction",
                "lambda:RemovePermission",
                "lambda:TagResource"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:lambda:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:function:<<RESOURCE_NAMING_PREFIX>>*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "LogsActionsFromCloudFormation",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:DeleteLogGroup"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:logs:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:log-group:<<RESOURCE_NAMING_PREFIX>>*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "LogsActionsFromCloudFormation2",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:DeleteLogGroup",
                "logs:PutRetentionPolicy"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:logs:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:log-group:/aws/lambda/<<RESOURCE_NAMING_PREFIX>>*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "SsmActionsFromCloudFormation",
            "Effect": "Allow",
            "Action": [
                "ssm:AddTagsToResource",
                "ssm:CreateDocument",
                "ssm:DeleteDocument",
                "ssm:DescribeDocument",
                "ssm:GetDocument"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:ssm:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:document/<<RESOURCE_NAMING_PREFIX>>*",
            "Condition": {
                "StringEquals": {
                    "aws:CalledViaFirst": [
                        "cloudformation.<<AWS_URL_SUFFIX>>"
                    ]
                }
            }
        },
        {
            "Sid": "EC2StopStart",
            "Effect": "Allow",
            "Action": [
                "ec2:StartInstances",
                "ec2:StopInstances"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:ec2:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:instance/*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/mw-ProductID": "MathWorks-MATLAB-Linux"
                },
                "StringLike": {
                    "aws:ResourceTag/mw-StackName": "<<RESOURCE_NAMING_PREFIX>>*"
                }
            }
        },
        {
            "Sid": "ReadOnlyActionsForSmoothConsoleExperience",
            "Effect": "Allow",
            "Action": [
                "cloudformation:GetTemplateSummary",
                "cloudformation:ListStacks",
                "ec2:DescribeInstances",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "logs:DescribeLogGroups",
                "ssm:DescribeInstanceInformation",
                "ssm:GetConnectionStatus"
            ],
            "Resource": "*"
        },
        {
            "Sid": "EC2KeyPairWriteAccess",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateKeyPair",
                "ec2:DeleteKeyPair"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:ec2:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:key-pair/<<RESOURCE_NAMING_PREFIX>>*"
        },
        {
            "Sid": "CloudWatchLogsReadOnlyAccess",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogStreams",
                "logs:GetLogEvents"
            ],
            "Resource": [
                "arn:<<AWS_PARTITION>>:logs:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:log-group:/aws/lambda/<<RESOURCE_NAMING_PREFIX>>*",
                "arn:<<AWS_PARTITION>>:logs:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:log-group:<<RESOURCE_NAMING_PREFIX>>*"
            ]
        }
    ]
}
```

</details>

Since your users cannot create IAM roles within their CloudFormation stacks, you, as the AWS admin, must create a common IAM execution role and share its name with your team, enabling them to pass it to the CloudFormation template when deploying their stacks. You can create this role using the following JSON policies. Ensure you use the path '/MW/' and prefix the role name with the "Resource naming prefix" you specified in the provisioning policy. If you wish to grant more permissions to your user's EC2 instances, you can attach additional IAM policies to this role.

<details>

<summary>Policy for Common Execution Role</summary>

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/mw-ProductID": "MathWorks-MATLAB-Linux"
                }
            },
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:StopInstances"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:ec2:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:instance/*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:logs:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:log-group:<<RESOURCE_NAMING_PREFIX>>*",
            "Effect": "Allow"
        },
        {
            "Action": "s3:GetObject",
            "Resource": "arn:<<AWS_PARTITION>>:s3:::dcv-license.<<AWS_REGION>>/*",
            "Effect": "Allow"
        },
        {
            "Action": "ec2:DescribeTags",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:DescribeDocument",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:GetManifest",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:PutInventory",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "ec2:DescribeInstances",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:<<AWS_PARTITION>>:logs:<<AWS_REGION>>:<<AWS_ACCOUNT_ID>>:log-group:/aws/lambda/*EC2ShutdownLambda*",
            "Effect": "Allow"
        }
    ]
}
```

</details>

You can use this JSON as your Trust Policy for the Common Execution IAM Role.

<details>
<summary>Trust relationship JSON for execution role</summary>

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.<<AWS_URL_SUFFIX>>"
            },
            "Action": [
                "sts:AssumeRole"
            ]
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.<<AWS_URL_SUFFIX>>"
            },
            "Action": [
                "sts:AssumeRole"
            ]
        }
    ]
}

```

</details>

## Related Information

* [AWS Cloudformation FAQs](https://aws.amazon.com/cloudformation/faqs/)
* [AWS Identity and Access Management (IAM) FAQs](https://aws.amazon.com/iam/faqs/)
* [AWS IAM service documentation](https://aws.amazon.com/iam/)
* [IAM JSON policy reference](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies.html)
* [Security best practices in IAM & least-privileged access model](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html#grant-least-privilege)
* [How to use the PassRole permission with IAM roles](https://aws.amazon.com/blogs/security/how-to-use-the-passrole-permission-with-iam-roles/)
* [How to use trust policies with IAM roles](https://aws.amazon.com/blogs/security/how-to-use-trust-policies-with-iam-roles/)
* [How to implement the principle of least privilege with CloudFormation StackSets](https://aws.amazon.com/blogs/security/how-to-implement-the-principle-of-least-privilege-with-cloudformation-stacksets/)
* [Grant a user permissions to pass a role to an AWS service](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_passrole.html)

## Technical Support

To request assistance or additional features, contact [MathWorks Technical Support](https://www.mathworks.com/support/contact_us.html).

----

Copyright 2025 The MathWorks, Inc.

----