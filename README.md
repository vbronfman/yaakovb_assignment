# yaakovb_assignment
home assignment Yaakov B

## Part I:
Create CI/CD workflow in GitHub Actions:

1. Create k8s cluster + private docker registry (Skip this step if already exists)

2. Create docker image (nginx web server + php-fpm with index.php inside) 
- You should be able to modify the content of index.php file

3. Upload the image to the docker registry.

4. Pull the image from the docker registry and deploy it to the kubernetes cluster.

5. For branch develop, the deploy is done automatically on pull request while for
branch master the deploy is done by running the workflow manually.
6. The workflow should output the application’s service external ip.
Note: Make sure to hide sensitive data


## Part II:
Create a bash script that performs the following tasks using yq. Link to yq: HERE
The script will receive a command to execute and 2 yaml files as input.

##########
## Processing


docker build  -t yaakovb/php-fpm-nginx:$(git rev-parse --short HEAD) .

docker run --rm --name yaakovb-app -p 58080:80 yaakovb/php-fpm-nginx:$(git rev-parse --short HEAD)

created EKS with terraform 
created profile github-eks

aws eks update-kubeconfig --region <region> --name <cluster name> --profile  github-eks

_$ aws eks update-kubeconfig --region us-east-1 --name eks-workshop --profile github-eks_

K8S_EKS_NAME eks-workshop

ADD SECRETS AWS_ACCESS_KEY_ID AND AWS_SECRET_ACCESS_KEY 

Create secret in EKS to store docker credentials:
Manually:
kubectl create secret docker-registry regsecret \
--docker-server=docker.io \
--docker-username=vladbronfman \
--docker-password=xxxxxxxxxxxxxxx \
--docker-email=vlad.bronfman@gmail.com
secret/regsecret created
