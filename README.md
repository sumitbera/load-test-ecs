# Perform Load Test at scale using Jmeter, Docker, AWS ECS
Load Testing using Docker and AWS ECS

Our idea with this solution is to perform load test on a larger scale. This will help to understand the stress point of APIs along with improving the scalability of APIs to address high incoming traffic.

# Tech stack
1. Jmeter
2. Docker
3. AWS ECS
4. Grafana
5. InfluxDb  

# Architecture  
  ![Alt text](screenshots/arch.png "Architecture") 

# Let's implement this together :)
1.<b><u> Implement Load Test using Jmeter</u></b>    
For our example we are using open APIs of gorest endpoints. We are implementing below endpoints  
a) GET USERS (GET)  
b) GET POSTS (GET)  
c) CREATE USER (POST)  
d) DELETE USER (DELETE)  

* Each request is written in the form of HTTP Request sampler.  
* All the values are passed as environment variables from Env Variable step.  
* Trees, Table and Summary Report are used as Listeners to visualize the implementation results  

<b> Backend Listner is used to push the execution logs to influxDb server </b>  
<u>Note</u>: Always replace the server URL in the backend listener from Env variables step <i>"influxdbUrl"<i> 

2. <b><u> Dockarize your Jmeter Test </u></b>  
a) Create a docker repository in <b>AWS Elastic Container Registry (ECR)</b>.  
b) Once you have the docker repository ready follow the push commands in order to build, tag and push the docker image from your local machine.  

3. <b><u> Set Up Grafana on AWS EC2 </u></b>  

We are using Grafana in order to visualize the execution of load test in near real time.  
a) Launch an EC2 instance from your EC2 console.  
b) You can assign an elastic IP if needed (optional).  
c) Enable port 3000 in your security group that is attached to your EC2 instance. As Grafana listen on this port number.  
d) SSH into the launched instance.  

<u>List of commands that needs to be executed after you successfully SSH into your instance</u>  
a) <b>sudo yum update -y</b> (To update packages in the newly launched instance).  
b) <b>sudo nano /etc/yum.repos.d/grafana.repo</b> (Creating repo for installing open source grafana).    
c) Add the below lines in the file created from above step 2.  
```  
[grafana]  
name=grafana  
baseurl=https://packages.grafana.com/oss/rpm  
repo_gpgcheck=1  
enabled=1  
gpgcheck=1  
gpgkey=https://packages.grafana.com/gpg.key  
sslverify=1  
sslcacert=/etc/pki/tls/certs/ca-bundle.crt  
```
d) Install grafana using the command <b>sudo yum install grafana</b>  
e) Reload the systemd to load the new settings. Start Grafana Server, then check for its status using <b>sudo systemctl daemon-reload</b>  
f) Start the grafana server by using command <b>sudo systemctl start grafana-server</b>  
g) You can check the status if grafana is running by running the command <b> sudo systemctl status grafana-server. </b>  
h) Run the command below to make sure that Grafana will start upon booting our Amazon Linux 2 instance.  
<b>sudo systemctl enable grafana-server.service</b>  
 
5. <b><u> Testing your grafana server </u></b>  
a) Visit the newly installed Grafana Server by visiting the Public IP of the EC2 Instance on port <b>3000</b>.  
b) If everything has been setup correctly you should be redirected to grafana dashboard login page. (Access the dashboard by <b>http://{IP_ADDRESS_OF_SERVER}:3000</b>)  


![Alt text](screenshots/screen1.png "Grafana Dashboard")  

** By default username and password will be <b>admin</b>, Once you enter the details you will be redirected to change password screen where you can enter a new password (Input the desired password except admin) and click Save. **    

6) <b><u> Set Up InfluxDb on EC2 instance </u></b>  
a) Run the below command to create a influxdb repo.  

```
cat <<EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL 7
baseurl = https://repos.influxdata.com/rhel/7/x86_64/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF
```  
b) Run <b>sudo yum repolist</b> to confirm we've the repository added to our Amazon Linux 2.  
c) Now install influxdb using the command <b>sudo yum install influxdb.</b>  
d) Start the influxdb service using <b>sudo systemctl start influxdb.</b>  
e) Set the service to be started every time the server is restarted <b>sudo systemctl enable influxdb.</b>  
f) Check the status of influxdb using <b>systemctl status influxd.</b>  

** Important Note: Allow port 8086 and 8088 on your inbound rules of security group of your EC2 instance **

7. <b><u> Testing of influxDB </u></b>  
a) Run the following command  
```
curl -G http://localhost:8086/query --data-urlencode "q=SHOW DATABASES"  
```
b) You should see the output as below  
```
{"results":[{"statement_id":0,"series":[{"name":"databases","columns":["name"],"values":[["_internal"]]}]}]}  
```
8. <b><u> Setup Database </u></b>  
a) We will need to create a database to store our Jmeter Results. Open InfluxDB command line interface by executing command “influx” in terminal.  
b) Run ‘<b>SHOW DATABASES</b>’ command, you can see the list of all existing InfluxDB dabasebases. If you have just installed InfluxDB you should see only one ‘_internal’ database, which is used for keeping different stats about database itself:  

![Alt text](screenshots/screen2.png "Show Databases") 

** Run the command: “<b>CREATE DATABASE jmeter</b>” — here “jmeter” is the database name. **  

![Alt text](screenshots/screen3.png "Jmeter Database")

9. <b><u>Configure InfluxDb</b></u>  
a) Once we have created a database for our metrics, we need to make a few changes to the InfluxDB configuration. Use below command to open your influxdb.conf file  
```
sudo vim /etc/influxdb/influxdb.conf
```  
b) In this configuration file you need to find, uncomment and edit the ‘[[graphite]]’ category appropriately:
```
[[graphite]]  
# Determines whether the graphite endpoint is enabled.  
enabled = true  
database = "jmeter"  
retention-policy = ""  
bind-address = ":2003"  
protocol = "tcp"  
consistency-level = "one"  
batch-size = 5000  
batch-pending = 10  
batch-timeout = "1s"  
udp-read-buffer = 0  
separator = "."  
```  
c) After that you need to restart InfluxDB by applying an edited configuration:  
``` 
influxd -config /etc/influxdb/influxdb.conf
```  

10. <b><u>Set up cluster on AWS ECS</u></b>  
a) Enter the name of the cluster as shown below.  

![Alt text](screenshots/cluster_details.png "ECS Cluster name")  

b) Enter infrastructure details, In our case we are using <b>Amazon EC2 instance</b>  
* Min and Max instance can be any value based on your need (in our case we are keeping Min 1 and Max 3).  
* Operating system/Architecture again depends on your compute choices, we are using <b>Amazon Linux 2</b> here.  
* EC2 instance type depends on the level of scale at which you want to perform test, for our case we are using <b>t3.medium</b>

![Alt text](screenshots/infrastructure.png "ECS Infrastructure")  
c) Monitoring choice is optional, if you turn on <b>container insights</b> you will incure additional charges.  

![Alt text](screenshots/monitoring.png "ECS Cluster Monitoring") 

d) Click on <b>Create</b> button and within few minutes, your cluster will be up and running.  

![Alt text](screenshots/cluster.png "ECS Cluster")  

11. <b><u>Create Task definition in ECS</u></b>  
a) Next step is to create an ECS task definition.  
* Enter your task definition name.  
* Enter your ECR <b>repo name</b> and <b>docker image URI</b>.  
* Add container port <b>443</b>.  

![Alt text](screenshots/taskdef.png "ECS Task definition")  

b) Next is to add the environment variables under the environment variable section. Click on <b>Add environment variable.</b> and add all the Jmeter variables that needs to be passed as variable to the cluster.
```
NUMBER_OF_THREADS: 5
RAMP_UP_PERIOD: 1
HOST_URL: gorest.co.in
PORT: 443
LOOP_COUNT: 1
```  

![Alt text](screenshots/env.png "ECS Task definition Env variable") 

c) Once you click on Next you will be navigated to the envrionment section of task definition, where you have to select environment details.  
* Select app environment as <b>Amazon EC2</b>.  
* Under Container size, select your container from the drop down, rest all values can be set to default or based on your test requirement.  
* Under Monitoring and Logging, you can pick AWS Cloudwatch as your place to log all the execution logs.  

![Alt text](screenshots/monitoring-task.png "ECS Task Monitoring") 

d) Click on <b>Next</b> button and then click on <b>Create</b> button, Your task should be created in few minutes.  

![Alt text](screenshots/task.png "ECS Task") 
