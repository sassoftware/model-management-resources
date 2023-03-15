# Creating Container Images in an OpenShift Environment

SAS Viya platform uses Kaniko to create container images for models and decisions when they are published to a container publishing destination. Because Kaniko requires root access to run, container images cannot be created when the SAS Viya platform is deployed in a Red Hat OpenShift environment. 
In order to create container images within an OpenShift environment you must instead publish your models and decisions to a Git destination and then use Docker to create the container images.

_**Important:** This example should be used for SAS Viya 2022.12 and later stable releases._

## Prerequisites

* [Configure a Git publishing destination](https://documentation.sas.com/?cdcId=sasadmincdc&cdcVersion=default&docsetId=calpubdest&docsetTarget=p02scrqf37kexwn1gi60khpshifz.htm#p12x1jxk7gmtn0n1vaoqp9bhi18u).
* [Install Docker](https://docs.docker.com/get-docker/) on your local machine.
* Establish access from your local machine to the [mirror registry](https://documentation.sas.com/?cdcId=espcdc&cdcVersion=default&docsetId=dplyedge0phy0lax&docsetTarget=p13675fx02jyy7n1gs0t647n3vto.htm) for the SAS Viya platform repository that the SAS container images are pulled from.

## Steps for Creating a Container Image in an OpenShift Environment Using Docker

Here are the steps for creating a model or decision that is located within a Git repository using Docker:

1. Publish a model or decision to a Git publishing destination. 
   
   For more information, see [Publishing Models](https://documentation.sas.com/?cdcId=mdlmgrcdc&cdcVersion=default&docsetId=mdlmgrug&docsetTarget=p1takjngq2c47dn1g52oyk6gxk7k.htm) in _SAS Model Manager: User's Guide_ 
   or [Publishing a Decision](https://documentation.sas.com/?cdcId=edmcdc&cdcVersion=default&docsetId=edmug&docsetTarget=p0vq4w4n7debrgn19pyc1rh3co5e.htm) in _SAS Intelligent Decisioning: User's Guide_.


2. Clone or pull your Git repository using a local terminal.

   Here are examples of the Git commands:

   ```
   git clone ssh://git@gitlab.myserver.com:sasdemo/myGitRepository.git
   git pull origin main
   ```
   
3. Locate the container image for a model or decision within the Git repository.

   Here is an example of published model directory: 
   ```
   C:\<myGitRepository>\hpforest
   ```

4. Run a Docker build in the container image directory of your local Git repository using the following command. 
   This command looks for the "Dockerfile" and runs it.

   `docker build .`
   
   Here is an example of the Dockerfile in the hpforest directory:

   ```
   FROM repulpmaster.myserver.com /cdp-release-x64_oci_linux_2-docker-latest/sas-decisions-runtime-base:latest
   LABEL model container image
   USER root
   RUN chown sas:sas /modules
   USER sas
   ENV SAS_SCR_APP_PATH=/hpforest
   COPY --chown=sas:sas unzipped/ /modules/
   COPY --chown=sas:sas manifest/ /manifest/
   ENV LD_LIBRARY_PATH=/opt/scr/viya/home/SASFoundation/utilities/bin:/opt/scr/viya/home/SASFoundation/sasexe
   ```
   
5. Get the most recent container image ID using the following command and then copy it.

   `docker images`

   ```
   REPOSITORY                                     TAG         IMAGE ID       CREATED        SIZE
   <none>                                         <none>      cb6c66fc5bf3   25 hours ago   582MB
   ```

6. Log in to the remote Git repository using the following command.

   `docker login <myRemoteRepoURL>`


7. Tag the model or decision image within the Git repository, using the following command. The tag name can be a sequential number or descriptive text.

   `docker tag <image-id> <myRemoteRepoURL>/<published-name>:<myTagName>`


8. Verify that the tag was added using the following command.

    `docker images`

    ```
    REPOSITORY                                     TAG              IMAGE ID       CREATED        SIZE
    registry.myserver.com/sasdemo/mmdemo           Tag03132023      cb6c66fc5bf3   4 hours ago   582MB
    ```


8. Push the container image to the remote Git repository using the following command. The container image is then available for other users to pull it from the remote Git repository.

   `docker push <myRemoteRepoURL>/<published-name>:<myTagName>`
   
    Example: `docker push  registry.myserver.com/sasdemo/mmdemo/hpforest:Tag03132023`


For an example of executing a published decision or model that is contained in a SAS Container Runtime container image, 
see [Executing a Published Decision or Model](https://documentation.sas.com/?cdcId=mascrtcdc&cdcVersion=default&docsetId=mascrtag&docsetTarget=n12e5o7e0j8nipn1vtpjhuvcfdse.htm) in _SAS Container Runtime: Programming and Administration Guide_.

