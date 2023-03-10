
az login
az account set -n 'MCAPS-PRAGMATICAL-JL'
az aks get-versions -l westus3 -o table

export RESOURCE_GROUP_NAME=rg-k6labs
export CLUSTER_NAME=k6-cluster-02
export LOCATION=westus3

#Create cluster with byocni
az deployment group create \
    -g ${RESOURCE_GROUP_NAME} \
    -f aks.bicep \
    --parameters clusterName=${CLUSTER_NAME} @aks.parameters.json\
    --what-if 

#Install Cilium
az aks get-credentials --resource-group "${RESOURCE_GROUP_NAME}" --name "${CLUSTER_NAME}"
export CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)
export CLI_ARCH=amd64

cilium install --azure-resource-group "${RESOURCE_GROUP_NAME}"

cilium status --wait

#Enable Hubble


cilium hubble enable

export HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
export HUBBLE_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
rm hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}

cilium hubble port-forward&

hubble status

hubble observe


#Create storage account 

export STORAGE_RESOURCE_GROUP_NAME=rg-k6labs-storage
export STORAGE_ACCT_NAME=k6labssa

az group create \
  --name ${STORAGE_RESOURCE_GROUP_NAME} \
  --location ${LOCATION}

az storage account create \
  --name ${STORAGE_ACCT_NAME} \
  --resource-group ${STORAGE_RESOURCE_GROUP_NAME} \
  --location ${LOCATION} \
  --sku Standard_LRS \
  --kind StorageV2

az identity create -g ${STORAGE_RESOURCE_GROUP_NAME} -n lokiasidentity

wget http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&client_id=d3c46a21-0699-4e8e-8bbf-eb33110a8184&resource=https%3A%2F%2Fk6labssa.blob.core.windows.net



http://169.254.169.254/metadata/identity/oauth2/token?audience=https%3A%2F%2Fk6labssa.blob.core.windows.net

curl 'http://169.254.169.254/metadata/identity/oauth2/token?client_id=4f02778a-3162-4998-8743-1d70c391015e&resource=https://k6labssa.blob.core.windows.net&api-version=2018-02-01' -H "Metadata: true"
