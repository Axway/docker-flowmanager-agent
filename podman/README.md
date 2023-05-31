# Agent podman

This README refers to managing installations of Flow Manager Agent using `podman`

## Requirements

* [podman](https://podman.io/getting-started/installation) version 3.0.x or higher
* FlowManager-Agent docker image from [https//support.axway.com]

## ***Setup & Run***

* Get the image from [https//support.axway.com]
* Generate and register DOSA key in AMPLIFY platform:

    1. Generate a public/private key in `./files/agent/dosa-key.pem` `./files/agent/dosa-public.pem`
      -`openssl genrsa -out "./files/agent/dosa-key.pem" 2048`
      -`openssl rsa -in "./files/agent/dosa-key.pem" -outform PEM -pubout -out "./files/agent/dosa-key.pem"`
    2. Create a Service Account in [https://apicentral.axway.com/access/service-accounts]
      -you need to have an administrator role
    3. Copy the generated DOSA json file in `./files/agent/dosa.json`
    
* Configure `agent.yml` in the `env` section:
    ```sh
    NAME=GLOBAL                            # Choose an appropriate name for your agent/network zone
    DOSA_CERT=/conf/dosa-public.pem        # generate a x509 rsa:4096 key pair to be used to create service account
    DOSA_KEY=/conf/dosa-key.pem            #
    DOSA_KEY_PASSWORD=""                   # If dosa-key is protected
    DOSA=/conf/dosa.json                   
    ```
* Start agent using `./agent_helper.sh start`

## ***Remove***

* Be sure you are in the same `podman` path
* Type `./agent_helper.sh delete`, this will remove all the containers, volumes and other parts related to the containers.
