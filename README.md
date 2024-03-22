# yaakovb_assignment
home assignment Yaakov B

## Description

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

### Processing

The project employs preprovisioned EKS cluster
Created EKS with terraform K8S_EKS_NAME = "eks-workshop"
or
Create with _eksctl create cluster --name eks-workshop --region us-east-1 --managed --profile github-eks_

> [!NOTE]
> _$ aws eks update-kubeconfig --region us-east-1 --name eks-workshop --profile github-eks_

1. Create Github flow secrets for DOCKER_* credentials of private repo. 

the project employs DockerHub

2. Create Github flow secrets to store AWS_ACCESS_KEY_ID AND AWS_SECRET_ACCESS_KEY 

Required due to use by AWS eksctl tool to get access into EKS

3. 


>[!NOTE] External IP issue. 
> The workflow prints FQN of service instead of IP. This is the issue of the EKS cluster itself. 
> For reason unclear LoadBalancer service has no spec of external IP.
> I've spent quite a while troubleshooting, including deploynig of numerous EKS, but with a little 
> success. THe issue certainly workable but right now I'm running out of time.


### TODO
1. The pipelines lakes test and validations
2. There are hardcoded values.
3. When considering the Kubernetes aspect, the pipeline lacks portability.
4. The folders tree ill-structured

### REFERENCES
https://nicwortel.nl/blog/2022/continuous-deployment-to-kubernetes-with-github-actions 

## Part II:
Create a bash script that performs the following tasks using yq. Link to yq: HERE
The script will receive a command to execute and 2 yaml files as input.
>[!NOTE] The script must be generic for any two yaml files.
Help()
{
# Display Help
echo "Provide at least one argument"
echo "Script options:"
echo
echo "Syntax: ./run.sh <option> <file1> <file2>"
echo "options:"
echo " merge Merge the files"
echo " unique Extract the Unique keys along with their values"
echo " common Extract the Common (key, value) pairs"
echo " sort Sort the files by key"
echo
}

>[!INFO]
> $ ./run.sh
> Provide at least one argument
> Script options:
>
> Syntax: ./run.sh <option> <file1> <file2>
> options:
 merge Merge the files
 unique Extract the Unique keys along with their values
 common Extract the Common (key, value) pairs
 sort Sort the files by key
 
## DISCLAIMER
The request to manage all files is tough a little bit. There is plentry of edge cases with nested objects, multipart YAML manifests and so far. Sounds too optimistic try to address it within time given. 
Be that as it may, the project employs test files are comprised of examples out of 'yq' site itself.

>[!NOTE] with all due to respect, I haven't work with yq yet. This is my very first experience. 

>[!WARN] yq on git bash of Windows doesnt work as expected. yq 4.40.2 
 yq eval-all --inplace 'select(fileIndex == 0) * select(fileIndex == 1)' 1.yml 2.yml 
  yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' pod_nginx.yaml pod_busybox.yaml 

yq r read from 
Changing YAML values 
yq w pod.yaml "spec.containers[0].env[0].value" "postgres://prod:5432" 

Merging YAML files 
yq m --append pod.yaml envoy-pod.yaml
