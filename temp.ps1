https://www.docker.com/products/docker-desktop/
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
wsl --update
### Exercício "06a - Docker e Containers - FIAP 2TDCR-2025"
git clone https://github.com/corsec00/azure-voting-app.git
cd .\azure-voting-app\
docker-compose up -d
docker images
docker ps
docker-compose down

az login
$RG = "RG-PrincipalFIAPLins"
$myACR = "myacrleoss001"
az acr create --location "West Central US" --sku standard --admin-enable true --resource-group $RG --name $myACR 
az acr login --name $myACR
az acr list --resource-group $RG --query "[].{acrLoginServer:loginServer}" --output table
docker tag mcr.microsoft.com/azuredocs/azure-vote-front:v1 myacrleoss001.azurecr.io/azure-vote-front:v2

docker images
docker push myacrleoss001.azurecr.io/azure-vote-front:v2
az acr repository list --name $myACR --output table
az acr repository show-tags --name $myACR --repository azure-vote-front --output table


az acr delete -n $myACR --yes

# TS
## https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/config-file-is-not-available-when-connecting


docker tag besu:fiaptdc myacrleoss001.azurecr.io/besu:fiap2
docker push myacrleoss001.azurecr.io/besu:fiap2

### Exercício "06b - Kubernetes - FIAP 2TDCR-2025"
$myAKS="myAKSLeoSS001”
$RG="RG-PrincipalFIAPLins"
$NomeACR="myacrleoss001"
$loc="West US"
az aks create --resource-group $RG --name $myAKS --node-count 2 --generate-ssh-keys --attach-acr $NomeACR --location $loc
az aks get-credentials --resource-group $RG --name $myAKS
# No arquivo de Manifesto do Docker (azure-vote-all-in-one-redis.yaml) altere a localização do container para o seu ambiente 
kubectl apply -f azure-vote-all-in-one-redis.yaml
# Escalonando
kubectl get pods
kubectl scale --replicas=5 deployment/azure-vote-front
kubectl autoscale deployment azure-vote-front --cpu-percent=50 --min=3 --max=10
# Alterando a aplicação	
docker-compose up --build -d
docker tag mcr.microsoft.com/azuredocs/azure-vote-front:v1 myacrleoss001.azurecr.io/azure-vote-front:v3
az acr login --name $NomeACR
docker login -u $NomeACR -p "Key1 ou Key2" myacrleoss001.azurecr.io
docker push myacrleoss001.azurecr.io/azure-vote-front:v3
kubectl set image deployment azure-vote-front azure-vote-front=$NomeACR.azurecr.io/azure-vote-front:v3
# Atualizando o Cluster
az aks get-upgrades --resource-group $RG --name $myAKS
az aks upgrade --resource-group $RG --name $myAKS --kubernetes-version 1.32.1
# Perdendo os Pods
Kubectl delete pods azure-vote-front-cbb797db-ch9bv
kubectl get pods