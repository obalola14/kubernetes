resource "helm_release" "velero" {
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts/"
  chart      = "velero"
  version    = "7.1.5"
  namespace  = "velero"
  create_namespace =  true
  depends_on = [ module.eks ]

  values = [
    "${templatefile("values.yaml", { access_key = "${aws_iam_access_key.valero.id}", secret_access_key = "${aws_iam_access_key.valero.secret}", bucket_name = "${module.s3_bucket.s3_bucket_id}" })}"
  ]

}