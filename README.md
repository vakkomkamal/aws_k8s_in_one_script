# AWS_K8s_in_one_script
#A single script to deploy any application.



1. #This will create a new EKS cluster. 
2. #Will create a docker registry. 
3. #Will create a docker image (Build the stuffs inside the directory "worker"). 
4. #Deploy the docker image in a Kubernetes cluster. 
5. #You will be able to do kubectl through the system which you have run the script. 


a. #This will work only from a linux machine, if you are using windows, then please install virtualbox and 
  install a Ubuntu linux VM in it.
b. #Please also make sure that the docker engine is installed in your linux local machine
c. #Run "solution_start.sh" using the command "bash solution_start.sh"
d. #You can do this with a aws free tier account, login and go to IAM and create a user with "AdministerAccess" privilege
 and obtain AWS Access Key ID and AWS Secret Access Key
e. #you need to copy paste registryID upon docker registry creation. Will prompt for registryID< just need to copy from 
 above line, no need to go to console.


Contact:
Kamal Kailasa Babu
vakkomkamal@gmail.com
