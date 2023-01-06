
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
