
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

bash ca-permission-generator.sh cluster_name=$cluster_name resource_group="$resource_group" > ./cluster-autoscaler/aks-cluster-autoscaler-helm/templates/ca-secret.yaml

agentPool="$(kubectl get nodes -o json | jq --raw-output '.items[0].metadata.labels.agentpool')"

readonly ca_image_repository=k8s.gcr.io/cluster-autoscaler
readonly ca_image_tag=v1.2.2

helm install --dry-run --debug ./cluster-autoscaler/aks-cluster-autoscaler-helm --set nodes.min=$min_nodes,nodes.max=$max_nodes,nodes.agentpool=$agentPool,image.repository=$ca_image_repository,image.tag=$ca_image_tag --set rbac.create=false --set serviceAccount.create=false

#helm install ./aks-cluster-autoscaler --set nodes.min=$min_nodes,nodes.max=$max_nodes,nodes.agentpool=$agentPool,image.repository=$ca_image_repository,image.tag=$ca_image_tag --set global.rbacEnable=false

#helm install ./aks-cluster-autoscaler --set rbac.create=false

#rm ./cluster-autoscaler/aks-cluster-autoscaler/templates/ca-secret.yaml

kubectl -n kube-system describe configmap cluster-autoscaler-status

echo Cluster Autoscaling provisioned! This cluster can scale down to a minimum of $min_nodes and maximum of $max_nodes nodes
