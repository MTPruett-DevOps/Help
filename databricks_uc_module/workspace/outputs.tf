output ClusterName {
  value = databricks_cluster.SharedCluster.cluster_name
}
output ClusterId {
  value = databricks_cluster.SharedCluster.cluster_id
}
output ClusterNodeType {
  value = databricks_cluster.SharedCluster.node_type_id
}
output ClusterPolicyId {
  value = data.databricks_cluster_policy.Shared.id
}