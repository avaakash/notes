
> medium-to-markdown@0.0.3 convert
> node index.js

[![Akash Shrivastava](https://miro.medium.com/fit/c/96/96/1*s1AuMCCSqI5ZW8plnjKMAg.jpeg)

](https://medium.com/?source=post_page-----b5bc5b6ac6b--------------------------------)[Akash Shrivastava](https://medium.com/?source=post_page-----b5bc5b6ac6b--------------------------------)Follow

Nov 9, 2021

·6 min read

Setting up LitmusChaos on Raspberry Pi Cluster
==============================================

This blog is a guide on how to set up LitmusChaos on a Raspberry Pi cluster. This kind of setup can be used for development or testing purposes, as it is cheaper than cloud-based services, and it overcomes any limitations on your personal system.

LitmusChaos is a toolset to do cloud-native chaos engineering. It provides tools to orchestrate chaos on Kubernetes to help SREs find weaknesses in their deployments. SREs use Litmus to run chaos experiments initially in the staging environment and eventually in production to find bugs, vulnerabilities. Fixing the weaknesses leads to increased resilience of the system.

You can use this setup to see LitmusChaos in action, as well as this, can be used for development level testing of services using Litmus.

Setting up a Raspberry Pi Cluster
=================================

This section is a guide on how to set up an RPi cluster to run Kubernetes with a Master and multiple Worker Nodes.

Hardware Required
-----------------

For setting up the RPi Cluster, we need the following hardware (minimum requirement)

1.  Raspberry Pis (at least 2, the 4 GB variant will be good enough)
2.  Power Hub for powering the Raspberry Pis
3.  Ethernet Cable(s)
4.  Router (Optional Wi-Fi)
5.  32 GB SD Card(s) (One for each RPi)
6.  MicroSD Card Reader (or MicroSD Slot on your Laptop)

Installing Operating System on SD Card
--------------------------------------

There are many Linux based distros available for RPis, you can go with the RaspiOS Lite, the only drawback is that it is only available for 32bit systems. Considering that, you can choose Ubuntu 20.02 Server, which is also lightweight (not as much as RaspiOS) but it has been working fine. For this article, I will be using Ubuntu 20.02 Server.

Raspberry Pi provides an [_official image tool_](https://www.raspberrypi.org/software/) for installing the operating system on SD Card, but you can use any other tool as well. Download the Ubuntu image from [_here_](https://cdimage.ubuntu.com/releases/20.04.2/release/ubuntu-20.04.2-preinstalled-server-arm64+raspi.img.xz)_._ Next, connect the SD card and open the image tool. Select _Choose OS_ option and then select _Custom Image_ option, select the ubuntu image you downloaded. Next, select the storage device and click on _Write_. This will take some time (from 5–20 minutes), once done, continue the same process for all other SD Cards.

After this, insert the SD Cards into the Raspberry Pis and power them on.

Connecting RPis to Wifi (Optional)
----------------------------------

If you want to use the RPis connected with Ethernet only then you can skip this step. Also if you have a mini-HDMI to HDMI converter, you don’t need an Ethernet cable to set up wifi, you can connect your RPis to a screen and follow the same process.

To connect your RPis to Wifi, you will have to first connect it with an Ethernet cable. Go to your router settings and get the IP address of the RPis. Then SSH into the RPis one by one and repeat the same step.

```
ssh ubuntu@<ip-addr-rpi>
```

Note: The default password is **_ubuntu_**

You need to find the network interface name first

```
iw dev | grep Interface
```

Now to connect to Wifi you have to edit the _netplan_ configuration

```
sudo nano /etc/netplan/50-cloud-init.yaml
```

Then add the following inside _network_ block

```
wifis:  
    <interface-name>:  
        dhcp4: true  
        optional: true  
        access-points:  
            "<your-wifi-ssid>”:  
                password: "<your-wifi-password>"
```

Save and exit the editor and then apply the new configuration

```
sudo netplan apply
```

Now your device should be connected to wifi, you can check by

```
ip a
```

Now, repeat the same process on all the Raspberry Pis and then you can disconnect the Ethernet cable.

Note: the IP address has changed.

Configuring Raspberry Pis for SSH
---------------------------------

First, change the hostname of the Pis so they are easy to distinguish.

For master node

```
sudo hostname-ctl set-hostname kmaster
```

For worker nodes

```
sudo hostname-ctl set-hostname knode<node number>
```

Now, on your system create SSH keys and authorize them for the RPis by following these steps

**Note: Following steps are to be followed on your system**

1.  Create a _.ssh_ directory if it doesn’t exist and cd into it

```
mkdir .ssh && cd .ssh
```

2\. Use ssh-keygen to create SSH keys for master and all worker nodes, name the keys according to the hostname of the nodes so it’s easy to find.

3\. Add the SSH keys to the ssh-agent

```
ssh-add kmaster  
ssh-add knode<node number>
```

4\. Copy the ssh-keys to the RPis

```
_\# Master node_  
ssh-copy-id -i ~/.ssh/kmaster.pub ubunut@<RPI-IP-ADDRESS>  
		  
_\# Worker node_  
ssh-copy-id -i ~/.ssh/knode<number>.pub ubuntu@<RPI-IP-ADDRESS>
```

If you had defined a static IP address for the RPis, you can use a hostname rather than an IP address

```
echo -e "<master node ip address>\\tkmaster" | sudo tee -a /etc/hosts  
echo -e "<worker node 1 ip address>\\tknode1" | sudo tee -a /etc/hosts
```

Now, try to login to the RPis to verify that everything is working fine

```
ssh ubuntu@kmaster  
ssh ubuntu@knode1
```

Installing Kubernetes on Raspberry Pi Cluster
=============================================

This section is a guide on how to install Kubernetes on Raspberry Pi Cluster with a Master and multiple Worker Nodes. We will be installing k3s because it is lightweight, you can install any other distribution as well.

Since we will be using Docker, follow the official docs to install, you can find them [_here_](https://docs.docker.com/engine/install/ubuntu/).

Installing K3s Master
---------------------

SSH into the master node

```
ssh ubuntu@kmaster
```

Now install K3s

```
curl -sfL [https://get.k3s.io](https://get.k3s.io) | sh -s - --docker
```

Verify that the installation was successful

```
sudo kubectl get nodes
```

Note: You can check the k3s service to debug if the installation was not successful

```
sudo systemctl status k3s
```

Installing K3s Nodes
--------------------

On your system, run the following command to get the node token from the k3s master

```
MASTER\_TOKEN=$(ssh ubuntu@kmaster "sudo cat /var/lib/rancher/k3s/server/node-token")
```

Now SSH into the node

```
ssh ubuntu@knode1
```

Install K3s agent

```
curl -sfL [http://get.k3s.io](http://get.k3s.io) | K3S\_URL=https://kmaster:6443 K3S\_TOKEN=$MASTER\_TOKEN sh -s - --docker
```

Verify that the K3s agent was installed successfully

```
sudo systemctl status k3s-agent
```

Kubectl
-------

Install _kubectl_, a command-line interface tool that allows you to run commands against a remote Kubernetes cluster.

Now, create a config file to access the RPis K3s Cluster

```
mkdir -p $HOME/.kube/k3s   
touch $HOME/.kube/k3s/config  
chmod 600 $HOME/.kube/k3s/config
```

Next, copy the k3s cluster configuration from the master node

```
ssh pi@kmaster "sudo cat /etc/rancher/k3s/k3s.yaml" **\>** $HOME/.kube/k3s/config
```

Edit the _k3s_ config file on the client machine and change the remote IP address of the _k3s_ master from `localhost/127.0.0.1` to `kmaster`

```
_\# Edit master config_  
nano $HOME/.kube/k3s/config  
     
_\# Search for the 'server' attribute located in -_   
_\# clusters:_  
_\# - cluster:_  
_\#   server:_ [_https://127.0.0.1:6443_](https://127.0.0.1:6443) _or_ [_https://localhost:6443_](https://localhost:6443)  
_#_  
_\# Change 'server' value to_ [_https://kmaster:6443_](https://kmaster:6443)_  
\# Do not change the port value_
```

Now, export _k3s_ config file path as `KUBECONFIG` environment variable to use the config

```
export KUBECONFIG=$HOME/.kube/k3s/config
```

Verify the setup

```
kubectl get nodes
```

Installing LitmusChaos on Raspberry Pi Cluster
==============================================

This section is a guide on how to install LitmusChaos 2.0 on Raspberry Pi Cluster with K3s

For installation, we will be following their [_docs_](https://litmusdocs-beta.netlify.app/docs/litmus-install-namespace-mode)_._ There are two ways to install, one is by using helm, other is by applying the YAML spec file. We will be installing using the YAML spec file, you can follow the other one if you want by going through their docs.

```
kubectl apply -f [https://litmuschaos.github.io/litmus/2.0.0/litmus-2.0.0.yaml](https://litmuschaos.github.io/litmus/2.0.0/litmus-2.0.0.yaml)
```

**Note**: You can find the latest version of litmus at [docs.litmuschaos.io](http://docs.litmuschaos.io)

Let’s verify that all the services are running, and there have been no issues

```
kubectl get pods -n litmus  
kubectl get svc -n litmus
```

You can now use the LitmusChaos dashboard by using this address

```
<master-node-ip>:<port>
```

Change the <master-node-ip> with the master node IP and the <port> with what is showing to you for the _litmusportal-frontend-service_ external port value, the one after 9091:<port> and then visit that address in your browser.

Add-Ons
=======

The /etc/hosts file sets to default after a restart, so you will have to keep adding the RPis IP every time you restart or you can run a startup script that will automatically set the values on every restart.

You can edit the _bash profile_ file on your system to use this _Kubeconfig_ and also add the ssh keys to the ssh-agent. In my system it was the _/home/username/.profile_ file, it might differ in your system. I added these lines to the profile

```
eval $(ssh-agent)  
ssh-add ~/.ssh/kmaster  
ssh-add ~/.ssh/knode1export KUBECONFIG=$HOME/.kube/k3s/config
```

Summary
=======

In this article, we first set up the Raspberry Pis cluster and then installed K3s on the cluster. After that, we installed LitmusChaos onto the K3s cluster. We can now proceed with injecting chaos using the portal. This kind of setup is beneficially for local development purposes, and you will be saving money on AWS servers.

You can join the LitmusChaos community on [_Github_](https://github.com/litmuschaos/litmus)  and [_Slack_](https://www.notepadonline.org/wmtBaRICHQ). The community is very active and tries to solve queries quickly.

I hope you enjoyed this journey and found the blog interesting. You can leave your queries or suggestions (appreciation as well) in the comments below.

Show your ❤️ with a ⭐ on our [Github](https://github.com/litmuschaos/litmus). To learn more about Litmus, check out the [Litmus documentation](https://docs.litmuschaos.io/). Thank you! 🙏

Thank you for reading

Akash Shrivastava

Software Engineer at Harness

[Linkedin](https://www.linkedin.com/in/avaakash/) | [Github](https://github.com/avaakash) | [Instagram](https://instagram.com/avaakash) | [Twitter](https://twitter.com/_avaakash_)
