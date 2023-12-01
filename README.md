Spark for EKS
	~60% of data teams using K8s? Study from 2022 from Data on K8S Group
	Data on EKS (DoEKS) OSS project from AWS
		Reference Architectures
		IaC Templates
		Best Practices
		Sample Test Code
	Internal Custom Terraform Providers
		Example: https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest
		Hooks into GitHub/Azure DevOps repo? Needs more investigation
		This method also appears to have some simplified ways of setting up resources: https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest
	Using AWS Cloud9 (or other Cloud IDE) may help solve some hesitancy to get into source code
	There are some tools like KubeCost and Grafana that are easy to set up to monitor EKS clusters.
		A good amount of configuration required, but using boilerplate may work here
	There is a gitSync tag in the airflow YAML file which allows for synchronization automatically between a git repo and Airflow. This can be used to deploy DAGs to Airflow, but would it work for multiple teams to one instance?
		Sounds like no. The answer they propose is a root repo with submodules that pull from other repos: https://github.com/apache/airflow/discussions/19381
		Another answer in there is to set up S3 sync and then just have steps to upload the DAGs into a common S3 bucket for use
United Airlines with DocumentDB
	Support for Elastic Clusters (PaaS instead of IaaS)
	Can trigger Lambda functions when DocumentDB records are changed
	Structure of talk is updating new features of product, and then client testimonial at 20 mins in
	Background -> Why -> Architecture -> Challenges/Solutions
	Applications read/write with DocumentDB. 
		MSK topics used between Mainframe and DocumentDB
		Aurora also populated from MSK for order history for analytics
Data Catalog
	Data Governance should include security around data
	Data Catalogs help Data Governance to determine what data is available and where
	Technical Catalog - Think Hive Metastore (Columns, Location, Names, etc)
		AWS Glue Data Catalog is AWS' solution here
	Business Catalog - Enhances metadata (What does a column name mean? etc)
		Amazon DataZone is AWS' solution here
	DataZone also has ability to federate access (request access, with approval process built-in)
	Verdict: DataZone is pretty interesting with its ability to request and provide access to datasets, but it is still not there, and will likely be AWS-specific only unless vendors decide to support.
	No current support for service accounts as consumers, so access is only for ad-hoc queries
		Work with AWS Glue is on the roadmap for this use case.
		There is also an API that vendors can implement in order to be both producers and consumers
Pragmatic Python
	Technologies:
		mkdocs-material
		pytest
		Pydantic
		Powertools for AWS Lambda
	Common stages:
		Project Setup
		Pre-Commit Check
		Pre-PR
		PR Checks
	Serverless Project:
		IaC
		Domain Code
		Tests
		Readiness (Secondary Requirement Work such as Reliability/Performance/Cost Optimization)
	Devs should own all four of these parts all the way through the lifecycle
	Architectural Layers helps split things up
		Example: Handler vs Domain
		This would allow easy unit testing for domain logic, separates it from the plumbing
		May be worth splitting all integration code out of the domain layer into Integration layer
		This can make testing easier, and switching infrastructure decisions (DynamoDB vs Aurora)
	Goal should be to never leave the IDE (using breakpoints against real cloud resources)
		No Mocks!
	Tests
		Unit -> Run Locally
		Integration -> Run Locally & On AWS. Majority of Tests
		E2E -> Run only on AWS
	Integration tests create test data, call Lambda handler without mocks, causing it to talk to real AWS resources
	What if we had a sandbox environment in Snowflake and a team was using Spark? Could we do something similar, talking to their Sandbox environment from their local environment???
	Stubber is a resource from botocore that allows mocking failures in AWS resources
		Doing this as integration test allows you to only mock what you need
	E2E tests should also include some unhappy paths (excplitly invalid authentication or authorization)
	For Lambda functions, you can add additional parameters with defaults to do dependency injection
	When receiving messages, it's useful to wrap model in a class that holds metadata such as source, timestamp, etc.
	You can use pytest_socket to disable all network connections from tests, to make sure you've got reliable unit tests
	To do E2E testing for async functions, force side effects you can monitor for.
		You can have a step function that gets the result and writes it to a DynamoDB table you can modify
		Make sure that the event metadata allows you to verify it is the result you're looking for.
		Use request.node.name to get name of the current test, and use that as the source so it'll trace through
	Powertools for AWS Lambda has a lot of libraries that can make Lambda jobs easier to write
	Tuna helps visualize stack traces for import time increases, from the Python output
	PySpy also does this for full executions
	PyInstrument tells you how long a specific area of code takes
	Source code and details on decisions made available here: https://github.com/ran-isenberg/serverless-python-demo
Expo
	DBT
		DBT Cloud adds a lot of stability and enforces the development process a bit better than DBT Core
		Theres a book out there on how to use DBT I should read
	Soda
		Competitor to GE
		Managed and OSS versions.
		Often seen as simpler to use than GE
		REST API can be used to trigger DQ checks in managed version
	Astronomer
		14 day free trial now available
AWS Amplify
	Amplify consists of DataSync using GraphQL and Authentication (through Cognito, Auth0, and Okta)
	Focuses on logic, not on infrastructure
	Amplify Gen2 released in preview last week
		Now built entirely on top of CDK
		This allows you to drill down for customization if necessary
		Completely done in TypeScript
		Now able to use a local sandbox for testing
		1:1 mapping between branches and shared environments
		Allows for ephemeral environments for QA
		Able to take a model and generate React code to do CRUD work on that model
	Frontend has access to typed versions from the backend model
	Steps from basic front-end to full application:
		Use CLI via npm to create boilerplate code
		amplify/auth contains authentication information (Cognito by default)
		amplify/data contains the models for the backend
			Models contain information about authorization and relationships between models
		npx amplify sandbox command allows for creating sandbox environment to deploy to
		amplify/backend.ts allows you to customize the resources that are being created using CDK
			To do this, pull the necessary parts out of the resource struct created, and modify properties as necessary
		Custom stacks can be created through a separate TS file and then hooked into the backend.ts file
		npx generate forms creates ui-components directory based on the models for CRUD operations
	AWS Secrets Manager can be pulled into the code as if they were an environment variable
	Support for many front-ends, like React, Angular, native mobile front-ends, etc
		Forms with script generator is only available for React
Aurora Limitless
	Reference tables and sharded tables
	Allows for forcing colocation of tables based on having the same keys (for joins)
	Uses SET commands to control sharding and table type (to avoid changing syntax)
	Internal sub-shards used to move data when a new shard is needed
	You can have standard tables alongside sharded tables
	Internal routers that can scale and shard computes, both of which can scale horizontally or vertically
	Official recommendation is to use serverless unless you need write scalability since you are hitting the limits on writes
	Separate endpoint for sharded tables, which can also be used for non-sharded tables
	There is some way to tag databases as sharded? Not clear on this
	Shards can split if necessary automatically
	Eventually, there will be a path to take existing tables and add them into sharding
SageMaker
	S3 -> AWS Glue Crawler -> AWS Glue Data Catalog -> Athena -> SageMaker
	Data Wrangler or PyAthena to get data from Athena
FinOps
	DevOps == Dev + Ops + QA
	FinOps == Engineer + Business + Account/Finance/Buyer
	Both are culture changes so everyone cares
	Cyclical Stages: Inform -> Optimize -> Operate
	"You build it, you run it" - DevOps
	GitOps - Infrastructure is defined next to application code in a Git repository.
		All is provisioned together
	GitFinOps - Integrating FInOps into the deployment process
		Recommends a step to determine expected cost for change before deployment
	Use DynamoDB for TFLock
	Cost is determined using SQS -> Lambda
	They are using the tool InfraCost (https://www.infracost.io/)
		It gives a nice itemized bill of the changes and how much they will cost
		The Lambda function just checks the bill to a limit and notifies for approval or auto-approves
		Usage can be specified manually in YAML file or it can read your AWS usage automatically on existing resources
	Sample repo: github.com/igor-ivaniuk/codepipeline-terraform
	Recommended to automatically generate YAML file on a regular schedule
Spark on EMR Serverless
	EMR Serverless is multi-AZ by default (traditional EMR is not)
	New Features
		Application capacity and job metrics in Cloudwatch
		Job-level cost visibility
		EMR Studio support
		Secrets Manager integration
	Switching to ARM64 (Graviton2 processors) gives 15% improvement in performance (from AWS)
	You can use docker images for all worker nodes to add libraries or UDFs automatically
	EMR 6.12 has new Spark optimizations on top of Apache Spark
		1.4x faster than EMR 6.9 (from AWS)
	Switching from Java 8 to Java 17 helps the runtime as well
	EMR Serverless is cheaper and allows you to get your hands dirty. Glue adds an extra abstraction layer on top.
		Focus for Glue is on the Visual ETL Tool
	For EMR Serverless, if you're running 24/7, you'll need to create a second cluster to upgrade the versions/images
	YARN queue management isn't currently supported in Serverless
	GoDaddy Story
		Current batch jobs are mostly (62%) short jobs, with a distinct schedule through the day
		Compared EMR on EC2 vs EMR Serverless across many different production jobs
		Saw 70% improvement moving from EMR on EC2 to EMR Serverless with Graviton2
		Learnings
			VPCs should cover all AZs to get DR
			Make sure that your subnets have enough IP addresses 
			Check that your Max concurrent vCPUs quota is big enough
			spark.dynamicAllocation.maxExecutor can be used to cost control number of executors
			spark.emr-serverless.executor.disk may need to be expanded for spilled data
Self-Service Infrastructure
    92% of companies use a platform team, but skill shortage is #1 blocker
    Training and cross pollination with other users evangelizing is key
    Challenges
        Security needs vs self-service
        User friction causes issues, including skill lack
    Principles
        It's a balancing act
             Opinionated vs Free
        Defining guardrails
        Know your customer
    Use private registry to codify best practices
    Journey: Adopt -> Standardize -> Scale
    Adopt doesn't use platform team
    Scale moves into self service and maintenance
    Terraform Cloud supports private registry and security policies built in
    Security policies support Hashicorp Sentinel and Open Policy Agent (OPA)
    Cloud also supports additional third party tasks for security and cost checking
    Terraform 1.6 adds tests for individual modules
    Terraform 1.5 also adds check block to define checks on consumers
    Test actually runs plan or apply, depending on test
    Plus tier Cloud customers have automatically generated tests to get started
    Cloud has ability to execute custom modules with no code (platform team creates module, and then dev teams don't need to code to use them)
    HCP Waypoint builds on this to create a "golden path" to creating applications.
    AWS service catalog allows ability to create modules through Terraform without having the underlying access
Microservices
   Strangler Fig Pattern
      To convert a monolith to micrservices, take new features and implement as microservices.
      Eventually you'll be able to refactor the monolith as more work is pulled out.
      AWS suggests an account for one or a few microservices
   Use AWS service which can automate the common infrastructure for this pattern when dealing with a web service
      This service creates the networking and routing to make this work. 
      Assumes the monolith is already in AWS
S3 Security
    For cross account access, both accounts need the policy.
    Using organizations for the target account can allow any roles in the organization access.
    S3 Access Points can be used if the bucket policy gets too big
        Can be created in a separate account if needed
    Suggestion not to use AWS managed KMS key, instead use default encryption
        Use CMK if extra security necessary
    S3 access groups allow for granting access to AD groups
    Recommendation to use CloudTrail over access logs for S3
    Use IAM policies to specify nonstandard callers to deny
        Called setting up a data perimeter. There is a white paper on this.
        Look at the organization it's coming from or what network the request is coming from.
    Ability now to set up double layer of encryption on data at rest If needed
    Recommended to use bucket keys if using KMS to reduce KMS request costs
    Should not use ACLs anymore. can use storage lens and cloudtrail to find any uses
    IAM Access Analyzer can be used for static analysis of permissions on bucket
Athena Connections
    Athena can connect to various data sources and run SQL queries on them (Ala Presto)
    You can also create custom connectors for things like REST API calls
        These connectors are written in Java
    Sample custom connector available here: https://github.com/awslabs/aws-athena-query-federation
    There are different functions that need to be implemented for this such as getting metadata, listing tables, getting data, etc.
    Allows for splits, for data split across multiple files or APIs that have pagination.
     This API also allows for massaging of columns and data as part of the data processing class.
     A separate class can be written to create UDFs that can be used on the data.
    Uses Apache Arrow under the hood
    This is built in Lambda and run there
     Results are read-only and stored in AWS Glue Data Catalog
Data Integration
    Support for many data sources to pull in data from third party data sources.
        Includes Snowflake
    Redshift connector has been updated
        Allows for push-down optimization
    New native connector for AWS OpenSearch
    These connectors work within the Glue visual ETL Tool
    New transformations have been added to Glue Visual editor
    There is now a "trusted adapter" for DBT that connects to AWS Glue for execution
    AWS Glue now supports larger worker types (up to 32 vCPUs and 128 GB of memory)
    AWS Glue now supports streaming in Visual ETL
        It now supports autoscaling and a smaller instance type to save cost
    Glue has built in sensitive data detection
        Recently added ability to have fine grained actions configured based on the type of data found
    Glue DQ supports DQ in transit and at rest.
        Also gives rule suggestions
        New ability to use ML to detect anomalies in the data
            This has to be configured with which metrics (like row count and column length) to do anomaly detection on.
             This does allow for seasonality
    MWAA now supports 2.7.2 which includes deferrable operators
        Also uses secrets caching for cost saving
        Also includes support for openlineage
    MWAA now supports shared VPCs
    AWS Glue integrates with git now better, for most (but not Azure DevOps) git providers
    Glue now exposes the Spark History Server UI for debugging
    