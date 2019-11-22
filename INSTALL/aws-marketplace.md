# AWS 软件市场 AMI

Kong 64位Amazon Machine Image (AMI)可在AWS市场上使用，只需一键式启动，或使用EC2控制台、api或CLI手动启动:

- Install Kong with from AWS Marketplace:https://aws.amazon.com/marketplace/pp/B06WP4TNKL

## 小贴士

1. **Cassandra**

	Kong AWS Marketplace AMI镜像旨在简化和快速部署，这意味着它与[Cassandra](https://docs.konghq.com/about/faq/#how-does-it-work)捆绑在同一镜像上。
    
    注意：*为了获得最佳性能，我们建议与Kong群集分开部署Cassandra群集。*
    
    请参考[AWS Cloud Formation 模板](https://docs.konghq.com/install/aws-cloudformation)，以在AWS上自定义部署Cassandra和Kong集群。

2. **Scaling**

	每个EC2节点都是独立的，同时运行Kong和Cassandra。为了添加更多节点并启动集群，您必须打开[Cassandra中的集群](https://docs.konghq.com/about/faq/#apache-cassandra)功能，并使用更新后的Cassandra信息修改每个节点的`kong.yml`。
    
 3. 使用Kong
 	
    只需5分钟的快速入门，即可快速学习如何使用Kong。