## IAM Roles and policies for Node
resource "aws_iam_role" "node-role" {
  name = "BahmniEKSNodeRole-${var.environment}"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  inline_policy {
    name = "aws-efs-csi-driver-policy"

    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "elasticfilesystem:DescribeAccessPoints",
            "elasticfilesystem:DescribeFileSystems",
            "elasticfilesystem:DescribeMountTargets",
          ],
          "Resource": var.efs_file_system_arn
        },
        {
          "Effect": "Allow",
          "Action": [
            "elasticfilesystem:CreateAccessPoint"
          ],
          "Resource": var.efs_file_system_arn,
          "Condition": {
            "StringLike": {
              "aws:RequestTag/efs.csi.aws.com/cluster": "true"
            }
          }
        },
        {
          "Effect": "Allow",
          "Action": "elasticfilesystem:DeleteAccessPoint",
          "Resource": var.efs_file_system_arn,
          "Condition": {
            "StringEquals": {
              "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
            }
          }
        }
      ]
    })
  }

  tags = {
    Name  = "BahmniEKSNodeRole-${var.environment}"
    owner = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-role.name
}

## IAM Roles and policies for Cluster

resource "aws_iam_role" "cluster-role" {
  name = "BahmniEKSClusterRole-${var.environment}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = {
    Name  = "BahmniEKSClusterRole-${var.environment}"
    owner = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "cluster_EKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster-role.name
}

resource "aws_iam_role_policy_attachment" "cluster_EKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster-role.name
}
