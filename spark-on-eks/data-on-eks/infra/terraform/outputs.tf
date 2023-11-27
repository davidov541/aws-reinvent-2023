output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${var.name}"
}


output "s3_bucket_id_spark" {
  description = "Spark S3 bucket ID for data, jobs, and logs"
  value       = try(module.spark_s3_bucket[0].s3_bucket_id, "")
}

output "s3_bucket_id_airflow_logs" {
  description = "Airflow logs S3 bucket ID"
  value       = try(module.airflow_s3_bucket[0].s3_bucket_id, "")
}

output "region" {
  description = "Region"
  value       = local.aws_region
}

output "karpenter" {
  description = "karpenter"
  value       =  try(module.eks_blueprints_addons.karpenter.node_iam_role_name, "")
}
