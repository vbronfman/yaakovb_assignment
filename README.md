# Yaakovb_assignment
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

## DISCLAIMER
I lake recent experience with Github Actions. It took me quite a while to search and learn. There are certain putfalls I didn't manage to overcome within time given.

> [!NOTE] External IP issue. 
> The workflow prints FQN of service instead of IP. This is the issue of the EKS cluster itself.
> THere is the topic refers the issue: https://github.com/eksctl-io/eksctl/issues/1640 
> For reason unclear LoadBalancer service has no spec of external IP.
> I've spent quite a while troubleshooting, including deploynig of numerous EKS, but with a little 
> success. THe issue certainly workable but right now I'm running out of time.

> [!NOTE]  there is an issue to trigger 'development' on pull_request.
> https://github.com/orgs/community/discussions/65321#discussioncomment-6852334 
> The Pull request created in a GitHub action does not trigger workflows with pull_request trigger
> The flow is triggered by "push" event like a charm.

PS J:\Develop\YaakovB_addignment> gh pr create -a "@me" --base development  --title "Merge to develop branch" --body "Trying to trigger flow" 

### TODO
1.   The pipelines lack tests and validations.
2.   There are hardcoded values.
3.   When considering the Kubernetes aspect, the pipeline lacks portability.
4.   The folder tree is ill-structured.

### REFERENCES
https://nicwortel.nl/blog/2022/continuous-deployment-to-kubernetes-with-github-actions 
https://dlmade.medium.com/ci-cd-with-github-action-and-aws-eks-5fd9714010cd
https://tech.europace.de/post/github-actions-output-variables-how-to/ 
https://dev.to/kitarp29/running-kubernetes-on-github-actions-f2c
https://komodor.com/blog/automating-kubernetes-deployments-with-github-actions/ 

## Part II:
Create a bash script that performs the following tasks using yq. Link to yq: HERE
The script will receive a command to execute and 2 yaml files as input.
The script must be generic for __any two yaml__ files.
```
Help()
{
### Display Help
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
```
## PROCESSING
1. Developed bash script:
> [!TIP]
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
 
2. Addressing the objectives: 

## DISCLAIMER
The author's background with 'yq' is next to nothing. Be that as it may, the challenge is accepted, and attempts are made to try and learn as much as possible in zero time.
Straigtforward approach to copy from product tutorials wasn's as successful:  example https://mikefarah.gitbook.io/yq/recipes#export-as-environment-variables-script-or-any-custom-format doesn't work on pod manifest
```
$ yq '.. |(( select(kind == "scalar" and parent | kind != "seq") | (path | join("_")) + "='\''" > + . + "'\''"),( select(kind == "seq") | (path | join("_")) + "=(" + (map("'\''" + . + "'\''") | join(",")) + ")"))> ' pod_busybox.yaml
Error: !!str () cannot be added to a !!map (spec.containers[0])
```

### SORT
Deeper plunges into the documentation yield definite success. There is a *sort_by(.key)* example that provides the solution. Grabbed as is. 

> [!IMPORTANT] the function uses '--inplace' flag. In case of multidoc YAML it effectively mangles separate docs into one.

### MERGE
Same comes to merge: borrowed as is with hope it works.


### COMMON
I suggest to meet a half way and going to assign a stopgap solution. It serves the purpose in certain extent.

__common()__ function uses __yq__ to transmutate content of YAML files into strings that represent full key and value pairs:

spec.containers.0.ports.0.containerPort = 80

metadata.labels.run = busybox

metadata.name = busybox

spec.containers.0.args.0 = sh

Then populates into assosiative arrays per file. Afterwards scripr runs over first array, test if there is same key in the second and print it out if positive.

### UNIQUE
A stop-gap - see [Common](#common)

## TODO
1. The code is pretty much POC and asks to be refactored to employ feratures of *yq* properly. 

## REFERENCES
https://mikefarah.gitbook.io/yq/usage/tips-and-tricks
https://gitlab.com/AndreCbrera/scripts/-/blob/main/yq.sh
https://github.com/mikefarah/yq/discussions/categories/q-a 
https://stackoverflow.com/questions/tagged/yq
