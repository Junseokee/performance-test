#####################
# EKS Cluster
#####################
resource "aws_eks_cluster" "app_cluster" {
  name     = "dps-test"
  role_arn = aws_iam_role.eks_master_role.arn
  version  = "1.28"
  vpc_config {
    subnet_ids             = aws_subnet.public_subnet[*].id
    endpoint_public_access = true
    public_access_cidrs = [
      "0.0.0.0/0"
    ]
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
  tags = {
    Name= "dps-test"
  }
}

#####################
# EKS Node Group
#####################

resource "aws_eks_node_group" "cd_nodes" {
  cluster_name    = aws_eks_cluster.app_cluster.name
  node_group_name = "${aws_eks_cluster.app_cluster.name}-ng"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = aws_subnet.public_subnet[*].id
  update_config {
    max_unavailable = 1
  }
  scaling_config {
    desired_size = 3
    min_size     = 3
    max_size     = 5
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]

  instance_types = ["c5.large"]
  capacity_type  = "ON_DEMAND"
  disk_size      = 20
  tags = {
    Name = "${aws_eks_cluster.app_cluster.name}-ng"
  }
}