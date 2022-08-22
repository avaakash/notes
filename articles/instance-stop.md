
> medium-to-markdown@0.0.3 convert
> node index.js

[![Akash Shrivastava](https://miro.medium.com/fit/c/96/96/1*s1AuMCCSqI5ZW8plnjKMAg.jpeg)

](https://medium.com/@avaakash?source=post_page-----63ae3bcdb9ad--------------------------------)[Akash Shrivastava](https://medium.com/@avaakash?source=post_page-----63ae3bcdb9ad--------------------------------)Follow

Aug 19, 2021

·5 min read

How to run Azure Instance Stop Experiment in LitmusChaos
========================================================

![](https://miro.medium.com/max/1400/1*u5MRbsyEFH9jnrmlRNpU8g.png)

This article is a guide for setting up and running the Azure Instance Stop experiment on LitmusChaos 2.0. The experiment causes the power off of one or more azure instance(s) for a certain chaos duration and then powers them on. The broad objective of this experiment is to extend the principles of cloud-native chaos engineering to non-Kubernetes targets while ensuring resiliency for all kinds of targets, as a part of a single chaos workflow for the entirety of a business.

Pre-Requisites
==============

To run this experiment, we need a few things beforehand

1.  An Azure account
2.  A Virtual Machine Scale Set (or an Instance only)
3.  A Kubernetes cluster with LitmusChaos 2.0 installed (you can follow this blog to set up LitmusChaos 2.0 on AKS — [_Getting Started with LitmusChaos 2.0 in Azure Kubernetes Service_](https://medium.com/litmus-chaos/litmus-in-aks-f8838cfc551f))

Setting up Azure Credentials as Kubernetes Secret
=================================================

To let LitmusChaos access your Azure instances, you need to set up the azure credentials as a Kubernetes secret. It is a very simple process, first, you need to install Azure CLI (if you already haven’t) and log in to it. Now run this command to get the azure credentials saved in an _azure.auth_ file.

```
az ad sp create-for-rbac — sdk-auth > azure.auth
```

Next, create a _secret.yaml_ file with the following content. Change the content inside _azure.auth_ with the contents inside your _azure.auth_ file

```
apiVersion: v1  
kind: Secret  
metadata:  
  name: cloud-secret  
type: Opaque  
stringData:  
  azure.auth: |-  
    {  
      "clientId": "XXXXXXXXX",  
      "clientSecret": "XXXXXXXXX",  
      "subscriptionId": "XXXXXXXXX",  
      "tenantId": "XXXXXXXXX",  
      "activeDirectoryEndpointUrl": "XXXXXXXXX",  
      "resourceManagerEndpointUrl": "XXXXXXXXX",  
      "activeDirectoryGraphResourceId": "XXXXXXXXX",  
      "sqlManagementEndpointUrl": "XXXXXXXXX",  
      "galleryEndpointUrl": "XXXXXXXXX",  
      "managementEndpointUrl": "XXXXXXXXX"  
    }
```

Now run the following command. Remember to change the namespace if you have installed LitmusChaos in any other namespace

```
kubectl apply -f secret.yaml -n litmus
```

Updating ChaosHub
=================

As the experiment is only available as a technical preview right now, we will have to update the ChaosHub to use the technical preview (master) branch.

Login to the Chaos Center and go to the ChaosHub section, select MyHub there and click on Edit Hub

![](https://miro.medium.com/max/1400/1*hlqxOFLnlZ_9b3uZ-IPpsw.png)

Now change the branch to “master”.

![](https://miro.medium.com/max/1400/1*ZiNzR4eL8ku4iIh8myObjQ.png)

Click on Submit Now and the ChaosHub will now show the Azure Instance Stop experiment.

Scheduling the Experiment Workflow
==================================

Now move to the Workflows section and click on Schedule a Workflow. Select the Self-Agent (or any other one if you have multiple agents installed) and click on Next.

![](https://miro.medium.com/max/1400/1*jSTrvNK3GYDg3Qp5siCnDg.png)

Select the third option to create a workflow from experiments using ChaosHub. Click on Next.

![](https://miro.medium.com/max/1400/1*0E5BalV9CQWFTqCkEz8Wyw.png)

Click Next again (or edit the workflow name if you want to) and now on the Experiments page, click on Add a new Experiment and select the Azure Instance Stop experiment.

![](https://miro.medium.com/max/1400/1*0gD3kIvUsyz9WuWSjKhbnQ.png)

Next click on Edit YAML, you will now have to add the Instance Name(s) and Resource Group name in the ChaosEngine environments. Scroll down to the ChaosEngine artefacts, where you will see the environment variables, and set the values accordingly. If you are injecting chaos on a Scale Set, set the SCALE\_SET to “enable”. Save the changes and schedule your workflow

![](https://miro.medium.com/max/1400/1*FTfE1yOBIQxSjIgLcJ8rIA.png)

**Note**: You need to provide the instance name from the Virtual Machine Scale Set section for Azure AKS nodes, not from the AKS node pools section.

![](https://miro.medium.com/max/1400/1*8upszlv4RP-5cmR6MWeMjg.png)Azure Virtual Machine Scale Set Instances section

Observing the Experiment Run
============================

Great, now your workflow is running and you can check it out, click on Go to Workflow and then select your workflow.

![](https://miro.medium.com/max/1400/1*4SXDitLKyJGsqM1QInxf0A.png)

You can check the status of your instance in the Azure Portal to verify that the experiment is working as expected.

![](https://miro.medium.com/max/1400/1*Kfd4MGH0FL8Gmofy3D6d0g.png)

You can also click on azure-instance-stop to view the experiment logs. After the given chaos duration, the experiment will automatically power on the instance(s) to give a pass/fail verdict. In case the experiment fails, verify through the logs and portal that the instances have started.

![](https://miro.medium.com/max/1400/1*VqdyLQ69YTSFS5qR5UbqoQ.png)

This was it, you have successfully run the Azure Instance Stop experiment using LitmusChaos 2.0 Chaos Center.

![](https://miro.medium.com/max/1400/1*b62g91Uq8utVzZkug6mCzA.png)

In this blog, we saw how we can perform the Azure Instance Stop experiment using LitmusChaos 2.0. You can learn more about this experiment from the [docs](https://litmuschaos.github.io/litmus/experiments/categories/azure/azure-instance-stop/). This experiment is one of the many experiments Non-Kubernetes experiments in LitmusChaos, including experiments for AWS, GKS, and VMWare, which are targeted toward making Litmus an absolute Chaos Engineering toolset for every enterprise regardless of the technology stack used.

You can join the LitmusChaos community on [_Github_](https://github.com/litmuschaos/litmus)  and [_Slack_](https://www.notepadonline.org/wmtBaRICHQ). The community is very active and tries to solve queries quickly.

I hope you enjoyed this journey and found the blog interesting. You can leave your queries or suggestions (appreciation as well) in the comments below.

Show your ❤️ with a ⭐ on our [Github](https://github.com/litmuschaos/litmus). To learn more about Litmus, check out the [Litmus documentation](https://docs.litmuschaos.io/). Thank you! 🙏

Thank you for reading

Akash Shrivastava

Software Engineer at Harness

[Linkedin](https://www.linkedin.com/in/avaakash/) | [Github](https://github.com/avaakash) | [Instagram](https://instagram.com/avaakash) | [Twitter](https://twitter.com/_avaakash_)
