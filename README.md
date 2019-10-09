# Planet Lia Infrastructure

| Service                          | Status                                                                                            |
| -------------------------------- |:-------------------------------------------------------------------------------------------------:|
| Planet-Lia Platform Backend Core | ![](https://argocd.production.cloud.planetlia.com/api/badge?name=planetlia-platform-backend-core) |
| Argo-CD                          | ![](https://argocd.production.cloud.planetlia.com/api/badge?name=argo-cd)                         |
| Cert-Manager                     | ![](https://argocd.production.cloud.planetlia.com/api/badge?name=cert-manager)                    |
| Nginx-Ingress                    | ![](https://argocd.production.cloud.planetlia.com/api/badge?name=nginx-ingress)                   |


## About
This repository holds the necessary configuration files and instructions to deploy our official production Planet Lia platform. 
In general this repository shouldn't be interesting since it contains just operational knowledge how we deploy our platform infrastructure. 
If however you are curious to see how we run our platform behind the scenes, you are welcome to take a look.

1. Create a cluster, see `cluster` directory for more info
2. Create a new overlay in `overlays` with the appropriate patches and secrets in the `secrets` dir (copy the template file and rename it to your clusters name)
3. Run `bash ./cluster/install_overlay.sh <OVERLAY_NAME>` (e.g. `bash ./cluster/install_overlay.sh production`) 

## Credits
Special thanks to the :crown: Kubernetes Wizard [dr. Mataž Pančur](https://fri.uni-lj.si/en/employees/matjaz-pancur) for his consulting on the  structure of the repository and Kubernetes in general. 