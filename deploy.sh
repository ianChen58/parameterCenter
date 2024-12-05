#!/bin/bash 
set -ex
# Default, overridable envvars, can be changed for prod
ENV="${ENV:-dev}"
REGION="${REGION:-us-west-2}"
ACCOUNT_ID="${ACCOUNT_ID:-565555147445}"

IMAGE_TAG="${ARCHERY_TAG:-"v"`date +%Y%m%d%H%M%S`}" 
IMAGE_REPO=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com 

# Image names
IMAGE_REPO_NAME="${IMAGE_REPO_NAME:-corebanking-base}"
IMAGE_NAME=$IMAGE_REPO_NAME:$IMAGE_TAG
IMAGE=$IMAGE_REPO/$IMAGE_NAME



IMAGE_DIR="."

buildNpm(){
  npm run build
}

buildImage(){
  echo "Building Docker Image"
  echo "IMAGE_REPO:"$IMAGE_REPO
  echo "IMAGE_NAME:"$IMAGE_NAME
  aws ecr describe-repositories --repository-names $IMAGE_REPO_NAME || aws ecr create-repository --repository-name $IMAGE_REPO_NAME --image-scanning-configuration scanOnPush=true --image-tag-mutability MUTABLE
  docker buildx build \
  --platform=linux/arm64 \
  --no-cache \
  -t $IMAGE_NAME  \
  -f docker/Dockerfile \
  $IMAGE_DIR
  docker tag  $IMAGE_NAME  $IMAGE
  docker push  $IMAGE 
  echo ""
  echo "Completed"
  echo ""
}

apply(){
  cp k8s-deploy/paramter-center-web-$ENV.yaml k8s-deploy/paramter-center-web-deploy.yaml
  sed -i -e 's|'{.*IMAGE_ID.*}'|'"$IMAGE"'|g' k8s-deploy/paramter-center-web-deploy.yaml
  cat k8s-deploy/paramter-center-web-deploy.yaml
  kubectl apply -f k8s-deploy/paramter-center-web-deploy.yaml
  rm -rf k8s-deploy/paramter-center-web-deploy*
}

installBuildx(){
    COUNT=`uname -a  | grep Darwin | wc -l`
  if [[ $COUNT == *1 ]];then
    echo build in mac.
  else
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    wget https://github.com/docker/buildx/releases/download/v0.4.1/buildx-v0.4.1.linux-amd64
    chmod a+x buildx-v0.4.1.linux-amd64
    mkdir -p ~/.docker/cli-plugins
    mv buildx-v0.4.1.linux-amd64 ~/.docker/cli-plugins/docker-buildx 
  fi
}

installKubectl(){
    COUNT=`which kubectl | wc -l`
  if [[ $COUNT == *1 ]];then
    echo found kubectl.
  else
    curl -LO "https://dl.k8s.io/release/v1.23.14/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    kubectl version
  fi
}

login(){
  aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $IMAGE_REPO
}

deploy(){
  # login
  login
  # # build npm
  buildNpm
  # # build image
  buildImage
  # # apply
  apply

  # createRoute53 控制台绑定route53，不在此处配置
}

determineRoute53Configuration() {
  DOMAIN_NAME=archery
  DNS_NAME=`kubectl get svc -n archery  | grep stori-archery-service-lb | awk -F " " '{print $4}'`

  case "${ENV}" in
    dev)

      ZONE_ID=Z18D5FSROUN65G
      HOSTED_NAME=storicarddev
      HOSTED_ID=Z0507899387TGM392YETK
    ;;
    qa)

      ZONE_ID=Z26RNL4JYFTOTI
      HOSTED_NAME=storicard-qa
      HOSTED_ID=Z00345942T51ZCT7WE3RD
    ;;
    prod)

      ZONE_ID=Z26RNL4JYFTOTI
      HOSTED_NAME=stori-core
      HOSTED_ID=Z0446760B18OLYTA6BA5
    ;;
    *)
      echo "${ENV} is not supported, supported env is: dev, qa, prod."
      exit 0
    ;;
  esac
}

# create route53 record if not exist.
createRoute53() {
  determineRoute53Configuration

  checkResult=`aws route53 list-resource-record-sets --hosted-zone-id /hostedzone/${HOSTED_ID} | grep ${DOMAIN_NAME}.${HOSTED_NAME}.com  | wc -l`

  if [[ $checkResult == *1 ]];then
    echo cm archery-conf has exsit.
    sed -i -e 's|'DNSPlaceholder'|'"${DNS_NAME}"'|g' conf/route53-update.json
    sed -i -e 's|'DomainNamePlaceHolder'|'"${DOMAIN_NAME}"'|g' conf/route53-update.json
    sed -i -e 's|'ZoneIdPlaceHolder'|'"${ZONE_ID}"'|g' conf/route53-update.json
    sed -i -e 's|'HostedNamePlaceHolder'|'"${HOSTED_NAME}"'|g' conf/route53-update.json
    aws route53 change-resource-record-sets --hosted-zone-id /hostedzone/${HOSTED_ID} --change-batch file://conf/route53-update.json
    exit 0
  fi


  sed -i -e 's|'DNSPlaceholder'|'"${DNS_NAME}"'|g' conf/route53.json
  sed -i -e 's|'DomainNamePlaceHolder'|'"${DOMAIN_NAME}"'|g' conf/route53.json
  sed -i -e 's|'ZoneIdPlaceHolder'|'"${ZONE_ID}"'|g' conf/route53.json
  sed -i -e 's|'HostedNamePlaceHolder'|'"${HOSTED_NAME}"'|g' conf/route53.json
  aws route53 change-resource-record-sets --hosted-zone-id /hostedzone/${HOSTED_ID} --change-batch file://conf/route53.json
}

# Execute Deploy
deploy
