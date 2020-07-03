#install kubectl

curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
kubectl version --short --client

echo "Installed kubectl"



#install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
echo "Installed eksctl"



#install aws-iam-authenticator
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
rm -rf aws-iam-authenticator
echo "installed aws-iam-authenticator"







#install aws cli
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
echo "Installed aws cli"
rm -rf aws
rm -rf awscliv2

echo "Please create a user with AdministratorAccess permission first and provide the below details"
aws configure



eksctl create cluster \
--name challenge \
--version 1.16 \
--region us-west-2 \
--nodegroup-name standard-workers \
--node-type t3.medium \
--nodes 1 \
--nodes-min 1 \
--nodes-max 1 \
--ssh-access \
--ssh-public-key ~/.ssh/id_rsa.pub \
--managed

#kubectl create deployment challenge --image=828546120056.dkr.ecr.us-west-2.amazonaws.com/challenge:latest
#kubectl create service LoadBalancer challenge --tcp=80:80


aws ecr create-repository \
    --repository-name challenge
echo "Enter the registryId from above: "
read Input
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 828546120056.dkr.ecr.us-west-2.amazonaws.com


cd worker
docker build -t $Input.dkr.ecr.us-west-2.amazonaws.com/challenge:latest .
docker push $Input.dkr.ecr.us-west-2.amazonaws.com/challenge:latest


sudo chmod 777 /var/run/docker.sock

cat <<EOF> deployment.yaml
apiVersion: v1
kind: Service
metadata:
  name: challenge
  labels:
    app: challenge
spec:
  type: LoadBalancer
  selector:
     app: challenge
  ports:
    - nodePort: 31479
      port: 8080
      targetPort: 3000


---
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: challenge
  labels:
    app: challenge
spec:
  selector:
    matchLabels:
      app: challenge
      tier: frontend
  strategy:
    type: Recreate
  template:
    metadata:
     labels:
        app: challenge
        tier: frontend
    spec:
      containers:
      - image: $Input.dkr.ecr.us-west-2.amazonaws.com/challenge:latest
        name: challenge
        ports:
        - containerPort: 3000
          name: challenge
EOF

kubectl apply -f deployment.yaml
kubectl get svc -o wide
echo "access website using external address and port 8080"


