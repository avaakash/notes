
> medium-to-markdown@0.0.3 convert
> node index.js

[![Akash Shrivastava](https://miro.medium.com/fit/c/96/96/1*s1AuMCCSqI5ZW8plnjKMAg.jpeg)

](https://medium.com/@avaakash?source=post_page-----f8838cfc551f--------------------------------)[Akash Shrivastava](https://medium.com/@avaakash?source=post_page-----f8838cfc551f--------------------------------)Follow

Jul 9, 2021

·8 min read

Getting Started with LitmusChaos 2.0 in Azure Kubernetes Service
================================================================

![](https://miro.medium.com/max/1400/1*DlUcR3cUAasfsbsGZLXfGw.png)

This is a quick tutorial on how to get started with LitmusChaos 2.0 in Azure Kubernetes Services. We will first create an AKS Cluster, followed by Installing LitmusChaos 2.0 on the cluster and then executing a simple pre-defined chaos workflow using LitmusChaos.

What is LitmusChaos
===================

LitmusChaos is a toolset to do cloud-native chaos engineering. It provides tools to orchestrate chaos on Kubernetes to help SREs find weaknesses in their deployments. SREs use Litmus to run chaos experiments initially in the staging environment and eventually in production to find bugs, vulnerabilities. Fixing the weaknesses leads to increased resilience of the system.

Litmus takes a cloud-native approach to create, manage and monitor chaos. Chaos is orchestrated using the following Kubernetes Custom Resource Definitions (CRDs):

*   ChaosEngine: A resource to link a Kubernetes application or Kubernetes node to a ChaosExperiment. ChaosEngine is watched by Litmus’ Chaos-Operator which then invokes Chaos-Experiments
*   ChaosExperiment: A resource to group the configuration parameters of a chaos experiment. ChaosExperiment CRs are created by the operator when experiments are invoked by ChaosEngine.
*   ChaosResult: A resource to hold the results of a chaos experiment. The Chaos-exporter reads the results and exports the metrics into a configured Prometheus server.

For more information, you can visit [litmuschaos.io](https://litmuschaos.io/) or [github.com/litmuschaos/litmus](https://github.com/litmuschaos/litmus)

Pre-Requisites
==============

1.  Azure CLI — [_How to install on Linux/Debian_](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)
2.  kubectl — [_How to install on Linux_](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)

If you feel lazy to install them, you can always use the Azure Cloud Shell, it already has the tools installed.

Creating an AKS Cluster
=======================

The first step to installing LitmusChaos on an AKS Cluster is to have an AKS Cluster. So let’s do that. Open [Azure Portal](http://portal.azure.com) and then log in with your account. You will be presented with the home screen. Now search for **Kubernetes services** and open it.

To create a cluster, click on create **Create** option in the menu and then select **Create a Kubernetes cluster**

![](https://miro.medium.com/max/1400/1*h9kw-ws6wDlHGtV7TkXRYg.png)Creating an AKS Cluster

Now you have to fill in details about what kind of cluster you want to create. Since Azure doesn’t charge for cluster management, you will only have to pay for the Node Instance you will be running. Fill in the name of the cluster, it can be anything, also create a new **Resource Group** if you haven’t. You can keep other settings as it is, or if you know what they do, can change it according to your need. For the **Node Pool**, select a **B2ms** size that has 2 vCPUs and 8 GiB of RAM and set the **Node Count** to 1 as we only want to run LitmusChaos, this will suffice for it. Although you are free to choose your configuration, keeping a minimum of 2 vCPUs and 8 GiB of RAM will help in seamless running. Remember to check that the **Scale Method** is set to **Manual** to keep a check on the cost.

![](https://miro.medium.com/max/1400/1*SzMPXjljSkLQzPSMHOcqbA.png)Configuring AKS cluster

You can skip the rest of the configurations for now and directly click on **Review+Create** which will start the creation of Cluster. It will take around 5–10 minutes, so you can sit back for some time, grab a glass of water, also read about [ChaosEngineering](https://medium.com/litmus-chaos/a-beginners-practical-guide-to-containerisation-and-chaos-engineering-with-litmuschaos-2-0-5f4f3cf2a55d) and [LitmusChaos 2.0](https://medium.com/litmus-chaos/litmus-2-0-simplifying-chaos-engineering-for-enterprises-5c3d73ca98d6)

![](https://miro.medium.com/max/1400/1*sUNFk5h6zYawvAcI1DBY7w.png)AKS Cluster Deployment in Progress

The cluster is ready and you can now install LitmusChaos on it. You can use the Azure Cloud Shell or your local system terminal to connect to the Cluster, the steps are the same for both. I personally prefer using my local system so I will use that for this tutorial.

Connecting to AKS Cluster
=========================

Open your cluster and click on the **Connect** button, this will show you two commands to run. Copy the two commands and run them one by one. The first command sets the account as per the subscription id provided, and the second command fetches the credentials for the specific resource.

![](https://miro.medium.com/max/1400/1*jxonYx2a6J5J9MLktD_gDg.png)Connecting to AKS Cluster

Installing LitmusChaos
======================

Now you have the credentials to access the Cluster, you can go ahead and install LitmusChaos 2.0 and do some chaos. For installation, I will be following their [_docs_](https://litmusdocs-beta.netlify.app/docs/litmus-install-namespace-mode)_._ There are two ways to install, one is by using helm, other is by applying the manifest file. I will follow the helm repo procedure, you can follow the other one if you want by going through their docs.

Note: You will need to have Helm installed on your system. You can refer from [_here_](https://helm.sh/docs/intro/install/)

First, you will add the LitmusChaos Helm repository and then confirm that litmuschaos is present in the helm repository

```
helm repo add litmuschaos [https://litmuschaos.github.io/litmus-helm/](https://litmuschaos.github.io/litmus-helm/)  
helm repo list
```![](https://miro.medium.com/max/1400/1*gm_0I5EqW6peY8pHvwjQ9g.png)Adding litmus to helm repo

Next, you will create the namespace, by default we use _litmus_ as the namespace name, you are allowed to use any name of your choice, just remember to change it in the following commands.

```
kubectl create ns litmus 
```

Now, let’s install LitmusChaos using the helm repository you just added.

```
_helm install chaos litmuschaos/litmus-2–0–0-beta --namespace=litmus --devel --set portalScope=namespace_
```![](https://miro.medium.com/max/1400/1*lkvbH9r8MY2i5fFrEpZgpQ.png)Creating litmus namespace and installing LitmusChaos

**Note:** If you are using helm2, you will have to run this command

```
helm install --name chaos litmuschaos/litmus-2–0–0-beta --namespace=litmus --devel --set portalScope=namespace
```

**The final step is to install the LitmusChaos CRDs**

```
kubectl apply -f [https://raw.githubusercontent.com/litmuschaos/litmus/master/litmus-portal/litmus-portal-crds.yml](https://raw.githubusercontent.com/litmuschaos/litmus/master/litmus-portal/litmus-portal-crds.yml)
```![](https://miro.medium.com/max/1400/1*Fy84STDtY3dNoqtYZiwo3A.png)Installing LitmusChaos CRDs

Let’s verify that all the services are running, and there has been no issue

![](https://miro.medium.com/max/1400/1*b84Y9wmPt7tagfYYtdCKTw.png)LitmusChaos Services

The services are running properly but there is one more change that you need to do, since AKS doesn’t provide public-IP to nodes by default, we need to change the **litmusportal-frontend-service** to a LoadBalancer service. You can do that by editing the service.

```
kubectl edit svc litmusportal-frontend-service -n litmus
```

At the very end inside **spec** there is **type: NodePort**, you have to change it to **type: LoadBalancer**

```
spec:  
 clusterIP: xxxxxxx  
 externalTrafficPolicy: Cluster  
 ports:  
 — name: http  
 nodePort: xxxxx  
 port: 9091  
 protocol: TCP  
 targetPort: 8080  
 selector:  
 app.kubernetes.io/component: litmus-2–0–0-beta-frontend  
 sessionAffinity: None  
 **\# Change the type here from NodePort to LoadBalancer**  
 **type: LoadBalancer**
```

Then save it, and list the services again. The External-IP might show pending for a minute, run the command again after a minute to get the IP.

![](https://miro.medium.com/max/1400/1*ob9_4b8bKYKuJcWkQadV1A.png)LitmusChaos Services```
<external-ip>:9091
```

Change the <external-ip> with what is showing to you for the _litmusportal-frontend-service_ and then visit the address in your browser.

![](https://miro.medium.com/max/1400/1*XK14XCer0Qtl9c2tePIYrA.png)LitmusChaos Portal sign-in page

Ta-da! We are done with the installation of LitmusChaos 2.0 and now you can run a workflow. Login to the portal, the default credentials are

```
username: admin  
password: litmus
```

It will ask you to set a new password, and then log in to the dashboard.

**Note**: Other than changing the frontend service to LoadBalancer, there is another way to make it work with NodePort by enabling public IP for individual nodes. I have not covered it in this article, but feel free to check it out [_here_](https://docs.microsoft.com/en-in/azure/aks/use-multiple-node-pools#assign-a-public-ip-per-node-for-your-node-pools)_._

Running Chaos Workflows
=======================

![](https://miro.medium.com/max/1400/1*5KPAt6av4N2PnsODJGBSQw.png)LitmusChaos Portal Dashboard Page

Let’s see some chaos happening now. LitmusChaos comes with few predefined workflows, which setups a service and then wreak havoc in them. We will be running a podtato-head workflow, which creates a simple deployment and then injects the pod-delete experiment into it.

On the dashboard select **Schedule a Workflow**. In the Workflows dashboard, select the **Self-Agent** and then click on **Next**. In the next screen, select **Create a Workflow from Pre-defined Templates** and then select **podtato-head** and then click on **Next**.

![](https://miro.medium.com/max/1400/1*iKXGW8MXmSyIyVAPdSeRLg.png)Scheduling a podtato-head template-based workflow

On the next screen, you can define the **Experiment name, description, and namespace,** leave the default values and click on **Next**.

On this screen, you can tune the workflow by editing the experiment manifest and adding/removing or arranging the experiments in the workflow. The podtato-head template comes with its own defined workflow so simply click on **Next**.

![](https://miro.medium.com/max/1400/1*E07spTCnDse0VO6t4lOd_g.png)Tuning the Workflow

The next screen is to adjust the weights of the experiment on the reliability score since you are running only one experiment, you can keep any value, in the case where you have multiple experiments running, you can set the importance of each experiment according to your requirements to get a meaningful reliability score. For now, click on **Next** and select **Schedule now**, you can also create a recurring schedule if you want the experiment to keep running at certain intervals. The final screen is to confirm the workflow and schedule it. Click on **Finish** to run the workflow

![](https://miro.medium.com/max/1400/1*L0kD_aMV1LnyGFjnqwiY3A.png)Workflow created

Yay! The workflow is created and is running now. Click on **Go to Workflow**, which will take you to the workflow screen, here you can see all your scheduled workflows. Click on the workflow to see its status.

![](https://miro.medium.com/max/1400/1*PtaormuGUIfTNQKu4sBLGQ.png)Workflow Dashboard Page

The workflow will take some minutes to run, you can take a break until then. Meanwhile, you can join the [LitmusChaos community on slack](https://www.notepadonline.org/wmtBaRICHQ) to stay updated with new releases and get help from the community.

![](https://miro.medium.com/max/1400/1*7wh-RJbU5tKcRIiLem-29Q.png)Workflow Dashboard for the podtato-head workflow

The workflow run is now complete, you can access the workflow details using the graph view or the table view.

![](https://miro.medium.com/max/1400/1*4EaKUgRHo_lTFfnvefTzGQ.png)Workflow Completed Graph View![](https://miro.medium.com/max/1400/1*N-buEbomJwEcjbnvoCOkbA.png)Workflow Completed Table View

Click on **View Logs & Results** to check out the logs and chaos results for the experiment

![](https://miro.medium.com/max/1400/1*-xSomN9TqmTwu1qh1chZTA.png)Experiment Logs and Results

And we are done. You were able to create an AKS Cluster, install LitmusChaos 2.0 on it, log in to the LitmusChaos Portal and then finally schedule a Workflow.

You can join the LitmusChaos community on [_Github_](https://github.com/litmuschaos/litmus)  and [_Slack_](https://www.notepadonline.org/wmtBaRICHQ). The community is very active and tries to solve queries quickly.

I hope you enjoyed this journey and found the blog interesting. You can leave your queries or suggestions (appreciation as well) in the comments below.

Show your ❤️ with a ⭐ on our [Github](https://github.com/litmuschaos/litmus). To learn more about Litmus, check out the [Litmus documentation](https://docs.litmuschaos.io/). Thank you! 🙏

Thank you for reading

Akash Shrivastava

Software Engineer at Harness

[Linkedin](https://www.linkedin.com/in/avaakash/) | [Github](https://github.com/avaakash) | [Instagram](https://instagram.com/avaakash) | [Twitter](https://twitter.com/_avaakash_)
