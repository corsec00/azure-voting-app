https://www.docker.com/products/docker-desktop/
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
wsl --update

git clone https://github.com/corsec00/azure-voting-app.git
cd .\azure-voting-app\
docker-compose up -d
docker images
docker ps
docker-compose down

az login
$RG = ""
$myACR = ""
# $loginServer =""
az acr create --location "North Central US" --sku standard --admin-enable true --resource-group $RG --name $myACR 
az acr login --name $myACR
az acr list --resource-group $RG --query "[].{acrLoginServer:logiServer}" --output table
docker tag mcr.microsoft.com/azuredocs/azure-vote-front:v1 myacrleoss001.azurecr.io/azure-vote-front:v2
docker images
docker push myacrleoss001.azurecr.io/azure-vote-front:v2
az acr repository list --name $myACR --output table
az acr repository show-tags --name $myACR --repository azure-vote-front --output table