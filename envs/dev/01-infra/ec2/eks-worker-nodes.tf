#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "uno-crm-node" {
  name = "terraform-eks-uno-crm-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "uno-crm-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.uno-crm-node.name
}

resource "aws_iam_role_policy_attachment" "uno-crm-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.uno-crm-node.name
}

resource "aws_iam_role_policy_attachment" "uno-crm-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.uno-crm-node.name
}

resource "aws_eks_node_group" "uno-crm" {
  cluster_name    = aws_eks_cluster.uno-crm.name
  node_group_name = "uno-crm"
  node_role_arn   = aws_iam_role.uno-crm-node.arn
  subnet_ids      = aws_subnet.uno-crm[*].id

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.uno-crm-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.uno-crm-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.uno-crm-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
