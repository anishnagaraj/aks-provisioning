
for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)
    case "$KEY" in
            cluster_name)      cluster_name=${VALUE} ;;
            resource_group)    resource_group=${VALUE} ;;
            min_nodes)         min_nodes=${VALUE} ;;
            max_nodes)         max_nodes=${VALUE} ;;
            *)
    esac
done


bash ca-permission-generator.sh cluster_name=$cluster_name resource_group="$resource_group" > ./cluster-autoscaler/aks-cluster-autoscaler-sed/ca-secret.yaml

agentPool="$(kubectl get nodes -o json | jq --raw-output '.items[0].metadata.labels.agentpool')"

#readonly ca_image_repository=k8s.gcr.io/cluster-autoscaler
#readonly ca_image_tag=v1.2.2

nodeConfig="$min_nodes:$max_nodes:$agentPool"

echo "nodeConfig: $nodeConfig"

sed "s/{{nodes:agentpool}}/$nodeConfig/g" ./cluster-autoscaler/aks-cluster-autoscaler-sed/ca-resource > ./cluster-autoscaler/aks-cluster-autoscaler-sed/ca-resource.yaml

kubectl apply -f ./cluster-autoscaler/aks-cluster-autoscaler-sed/.

rm ./cluster-autoscaler/aks-cluster-autoscaler-sed/ca-resource.yaml

rm ./cluster-autoscaler/aks-cluster-autoscaler-sed/ca-secret.yaml

kubectl -n kube-system describe configmap cluster-autoscaler-status

echo "Cluster Autoscaling provisioned! This cluster can scale down to a minimum of $min_nodes and maximum of $max_nodes nodes"
