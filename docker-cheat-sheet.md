# Docker & Docker Compose Cheat Sheet

---

## Table of Contents
1. [Docker Installation & Setup](#docker-installation--setup)
2. [Docker Images](#docker-images)
3. [Docker Containers](#docker-containers)
4. [Docker Volumes](#docker-volumes)
5. [Docker Networks](#docker-networks)
6. [Docker Compose](#docker-compose)
7. [Dockerfile](#dockerfile)
8. [Monitoring & Logs](#monitoring--logs)
9. [Swarm & Orchestration](#swarm--orchestration)
10. [Docker Security](#docker-security)
11. [Troubleshooting](#troubleshooting)
12. [Advanced Docker Commands](#advanced-docker-commands)

---

## Docker Installation & Setup

1. **Install Docker on Linux**  
   ```bash
   sudo apt-get install docker.io
   ```
2. **Check Docker version**  
   ```bash
   docker --version
   ```
3. **Enable Docker service**  
   ```bash
   sudo systemctl enable docker
   ```
4. **Start Docker service**  
   ```bash
   sudo systemctl start docker
   ```
5. **Add user to Docker group**  
   ```bash
   sudo usermod -aG docker $USER
   ```
6. **Check if Docker is running**  
   ```bash
   systemctl status docker
   ```
7. **Verify Docker installation**  
   ```bash
   docker run hello-world
   ```

---

## Docker Images

8. **List all images**  
   ```bash
   docker images
   ```
9. **Pull an image from Docker Hub**  
   ```bash
   docker pull <image-name>
   ```
10. **Search for an image on Docker Hub**  
    ```bash
    docker search <image-name>
    ```
11. **Remove an image**  
    ```bash
    docker rmi <image-id>
    ```
12. **Tag an image**  
    ```bash
    docker tag <image-id> <new-repo>:<tag>
    ```
13. **Build an image from a Dockerfile**  
    ```bash
    docker build -t <image-name> .
    ```
14. **Show image history**  
    ```bash
    docker history <image-id>
    ```
15. **Inspect image details**  
    ```bash
    docker inspect <image-id>
    ```
16. **Prune unused images**  
    ```bash
    docker image prune
    ```

---

## Docker Containers

17. **List running containers**  
    ```bash
    docker ps
    ```
18. **List all containers (stopped and running)**  
    ```bash
    docker ps -a
    ```
19. **Run a container interactively**  
    ```bash
    docker run -it <image-name>
    ```
20. **Run a container in detached mode**  
    ```bash
    docker run -d <image-name>
    ```
21. **Assign a name to a container**  
    ```bash
    docker run --name <container-name> <image-name>
    ```
22. **Run a container with a specific port mapping**  
    ```bash
    docker run -p 8080:80 <image-name>
    ```
23. **Stop a running container**  
    ```bash
    docker stop <container-id>
    ```
24. **Start a stopped container**  
    ```bash
    docker start <container-id>
    ```
25. **Remove a container**  
    ```bash
    docker rm <container-id>
    ```
26. **Restart a container**  
    ```bash
    docker restart <container-id>
    ```
27. **Rename a container**  
    ```bash
    docker rename <old-name> <new-name>
    ```
28. **Check container logs**  
    ```bash
    docker logs <container-id>
    ```
29. **Attach to a running container**  
    ```bash
    docker attach <container-id>
    ```
30. **Execute a command inside a running container**  
    ```bash
    docker exec -it <container-id> <command>
    ```

---

## Docker Volumes

31. **List all volumes**  
    ```bash
    docker volume ls
    ```
32. **Create a new volume**  
    ```bash
    docker volume create <volume-name>
    ```
33. **Inspect volume details**  
    ```bash
    docker volume inspect <volume-name>
    ```
34. **Remove a volume**  
    ```bash
    docker volume rm <volume-name>
    ```
35. **Prune unused volumes**  
    ```bash
    docker volume prune
    ```
36. **Mount a volume in a container**  
    ```bash
    docker run -v <volume-name>:/path <image-name>
    ```

---

## Docker Networks

37. **List all networks**  
    ```bash
    docker network ls
    ```
38. **Create a new network**  
    ```bash
    docker network create <network-name>
    ```
39. **Inspect network details**  
    ```bash
    docker network inspect <network-name>
    ```
40. **Connect a container to a network**  
    ```bash
    docker network connect <network-name> <container-id>
    ```
41. **Disconnect a container from a network**  
    ```bash
    docker network disconnect <network-name> <container-id>
    ```
42. **Remove a network**  
    ```bash
    docker network rm <network-name>
    ```

---

## Docker Compose

43. **Check Docker Compose version**  
    ```bash
    docker-compose --version
    ```
44. **Start all services**  
    ```bash
    docker-compose up
    ```
45. **Start services in detached mode**  
    ```bash
    docker-compose up -d
    ```
46. **Stop all services**  
    ```bash
    docker-compose down
    ```
47. **View running services**  
    ```bash
    docker-compose ps
    ```
48. **Build images for services**  
    ```bash
    docker-compose build
    ```
49. **View logs of services**  
    ```bash
    docker-compose logs
    ```
50. **Scale services**  
    ```bash
    docker-compose scale <service-name>=<count>
    ```

---

## Dockerfile

51. **Build an image with a Dockerfile**  
    ```bash
    docker build -t <image-name> .
    ```
52. **Use a specific Dockerfile**  
    ```bash
    docker build -f <dockerfile-path> -t <image-name> .
    ```
53. **Add build arguments**  
    ```bash
    docker build --build-arg <key>=<value> -t <image-name> .
    ```
---
### **Monitoring & Logs**

54. **Show container stats**  
    ```bash
    docker stats
    ```
55. **Display Docker events in real-time**  
    ```bash
    docker events
    ```
56. **View container logs (latest)**  
    ```bash
    docker logs <container-id>
    ```
57. **Follow container logs in real-time**  
    ```bash
    docker logs -f <container-id>
    ```
58. **Show specific lines from logs**  
    ```bash
    docker logs --tail 10 <container-id>
    ```
59. **Display logs for a time range**  
    ```bash
    docker logs --since "1h" <container-id>
    ```
60. **Inspect container resource usage**  
    ```bash
    docker stats <container-id>
    ```
61. **Display top processes inside a container**  
    ```bash
    docker top <container-id>
    ```

---

### **Swarm & Orchestration**

62. **Initialize a Swarm**  
    ```bash
    docker swarm init
    ```
63. **Join a worker node to a Swarm**  
    ```bash
    docker swarm join --token <worker-token> <manager-ip>:<port>
    ```
64. **List nodes in the Swarm**  
    ```bash
    docker node ls
    ```
65. **Create a service in the Swarm**  
    ```bash
    docker service create --name <service-name> <image-name>
    ```
66. **List services in the Swarm**  
    ```bash
    docker service ls
    ```
67. **Scale a service**  
    ```bash
    docker service scale <service-name>=<replicas>
    ```
68. **Inspect a service**  
    ```bash
    docker service inspect <service-name>
    ```
69. **List tasks for a service**  
    ```bash
    docker service ps <service-name>
    ```
70. **Update a service**  
    ```bash
    docker service update --image <new-image> <service-name>
    ```
71. **Remove a service**  
    ```bash
    docker service rm <service-name>
    ```

---

### **Docker Security**

72. **Scan an image for vulnerabilities**  
    ```bash
    docker scan <image-name>
    ```
73. **Use Docker Content Trust (DCT)**  
    ```bash
    export DOCKER_CONTENT_TRUST=1
    ```
74. **Limit container CPU usage**  
    ```bash
    docker run --cpus="1.5" <image-name>
    ```
75. **Limit container memory usage**  
    ```bash
    docker run --memory="256m" <image-name>
    ```
76. **Run a container in read-only mode**  
    ```bash
    docker run --read-only <image-name>
    ```
77. **Add environment variables securely**  
    ```bash
    docker run --env-file=<file-path> <image-name>
    ```
78. **Enable logging driver**  
    ```bash
    docker run --log-driver=json-file <image-name>
    ```

---

### **Troubleshooting**

79. **Check Docker daemon logs**  
    ```bash
    journalctl -u docker.service
    ```
80. **View container logs for errors**  
    ```bash
    docker logs <container-id>
    ```
81. **Verify container health status**  
    ```bash
    docker inspect --format='{{json .State.Health}}' <container-id>
    ```
82. **Test network connectivity between containers**  
    ```bash
    docker exec -it <container-id> ping <target-container>
    ```
83. **Check storage driver info**  
    ```bash
    docker info | grep "Storage Driver"
    ```
84. **Test DNS resolution inside a container**  
    ```bash
    docker exec -it <container-id> nslookup <domain>
    ```
85. **View container exit codes**  
    ```bash
    docker inspect <container-id> --format='{{.State.ExitCode}}'
    ```

---

### **Advanced Docker Commands**

86. **Commit changes to a new image**  
    ```bash
    docker commit <container-id> <new-image-name>
    ```
87. **Save an image as a tar file**  
    ```bash
    docker save -o <file.tar> <image-name>
    ```
88. **Load an image from a tar file**  
    ```bash
    docker load -i <file.tar>
    ```
89. **Export a container to a tar file**  
    ```bash
    docker export -o <file.tar> <container-id>
    ```
90. **Import a container from a tar file**  
    ```bash
    docker import <file.tar> <new-image-name>
    ```
91. **Push an image to Docker Hub**  
    ```bash
    docker push <repository>:<tag>
    ```
92. **Login to Docker Hub**  
    ```bash
    docker login
    ```
93. **Remove all stopped containers**  
    ```bash
    docker container prune
    ```
94. **Remove all unused images**  
    ```bash
    docker image prune -a
    ```
95. **Run a container with GPU access**  
    ```bash
    docker run --gpus all <image-name>
    ```

---

### **Docker Compose (Continued)**

96. **Restart all services**  
    ```bash
    docker-compose restart
    ```
97. **Stop specific services**  
    ```bash
    docker-compose stop <service-name>
    ```
98. **Remove stopped services**  
    ```bash
    docker-compose rm
    ```
99. **Execute a command in a service**  
    ```bash
    docker-compose exec <service-name> <command>
    ```
100. **Build services without cache**  
    ```bash
    docker-compose build --no-cache
    ```
101. **Start only selected services**  
    ```bash
    docker-compose up <service-name>
    ```
102. **View dependency graph**  
    ```bash
    docker-compose config
    ```
103. **Use an alternate Compose file**  
    ```bash
    docker-compose -f <file-name> up
    ```
104. **Check Compose YAML validity**  
    ```bash
    docker-compose config --quiet
    ```

---

### **Dockerfile (Continued)**

105. **Add a file or directory to the image**  
    ```dockerfile
    ADD <source> <destination>
    ```
106. **Copy files from host to image**  
    ```dockerfile
    COPY <source> <destination>
    ```
107. **Set working directory**  
    ```dockerfile
    WORKDIR /app
    ```
108. **Set environment variables**  
    ```dockerfile
    ENV KEY=value
    ```
109. **Expose a port**  
    ```dockerfile
    EXPOSE 8080
    ```
110. **Run a command during build**  
    ```dockerfile
    RUN <command>
    ```
111. **Set default command for container**  
    ```dockerfile
    CMD ["executable", "param1", "param2"]
    ```
112. **Set entry point for container**  
    ```dockerfile
    ENTRYPOINT ["executable", "param1"]
    ```
113. **Set build arguments**  
    ```dockerfile
    ARG <key>
    ```
Here's the **expanded continuation** of the **Docker and Docker Compose cheat sheet**, moving towards 250 commands across all aspects.

---

### **Networking**

114. **List all networks**  
    ```bash
    docker network ls
    ```
115. **Inspect a network**  
    ```bash
    docker network inspect <network-name>
    ```
116. **Create a bridge network**  
    ```bash
    docker network create <network-name>
    ```
117. **Create an overlay network**  
    ```bash
    docker network create --driver overlay <network-name>
    ```
118. **Remove a network**  
    ```bash
    docker network rm <network-name>
    ```
119. **Connect a container to a network**  
    ```bash
    docker network connect <network-name> <container-id>
    ```
120. **Disconnect a container from a network**  
    ```bash
    docker network disconnect <network-name> <container-id>
    ```
121. **Run a container in a specific network**  
    ```bash
    docker run --network <network-name> <image-name>
    ```
122. **Run a container with a specific hostname**  
    ```bash
    docker run --hostname <hostname> <image-name>
    ```
123. **Add DNS server to a container**  
    ```bash
    docker run --dns <dns-server-ip> <image-name>
    ```

---

### **Volumes**

124. **List all volumes**  
    ```bash
    docker volume ls
    ```
125. **Inspect a volume**  
    ```bash
    docker volume inspect <volume-name>
    ```
126. **Create a volume**  
    ```bash
    docker volume create <volume-name>
    ```
127. **Remove a volume**  
    ```bash
    docker volume rm <volume-name>
    ```
128. **Remove unused volumes**  
    ```bash
    docker volume prune
    ```
129. **Mount a volume to a container**  
    ```bash
    docker run -v <volume-name>:/path <image-name>
    ```
130. **Create a named volume with specific options**  
    ```bash
    docker volume create --driver local --opt type=tmpfs --opt device=tmpfs <volume-name>
    ```

---

### **Build and Image Optimization**

131. **Build an image from a Dockerfile**  
    ```bash
    docker build -t <image-name>:<tag> .
    ```
132. **Build image without cache**  
    ```bash
    docker build --no-cache -t <image-name>:<tag> .
    ```
133. **View build stages in Dockerfile**  
    ```bash
    docker build --target <stage-name> -t <image-name> .
    ```
134. **Compress image layers**  
    ```bash
    docker save <image-name> | gzip > <file.tar.gz>
    ```
135. **Add build-time arguments**  
    ```bash
    docker build --build-arg <key>=<value> -t <image-name> .
    ```
136. **Enable multi-stage builds**  
    ```dockerfile
    FROM <base-image> AS build
    ```
137. **Tag an existing image**  
    ```bash
    docker tag <source-image>:<tag> <target-image>:<tag>
    ```
138. **Clean up unused build cache**  
    ```bash
    docker builder prune
    ```

---

### **Container Management (Continued)**

139. **Start a stopped container**  
    ```bash
    docker start <container-id>
    ```
140. **Restart a running container**  
    ```bash
    docker restart <container-id>
    ```
141. **Stop a running container**  
    ```bash
    docker stop <container-id>
    ```
142. **Remove a stopped container**  
    ```bash
    docker rm <container-id>
    ```
143. **Rename a container**  
    ```bash
    docker rename <old-name> <new-name>
    ```
144. **Copy files from host to container**  
    ```bash
    docker cp <source-path> <container-id>:<target-path>
    ```
145. **Copy files from container to host**  
    ```bash
    docker cp <container-id>:<source-path> <target-path>
    ```
146. **Kill a container immediately**  
    ```bash
    docker kill <container-id>
    ```

---

### **Compose Networking**

147. **Create a custom network in Compose**  
    ```yaml
    networks:
      custom_network:
        driver: bridge
    ```
148. **Use a custom network in a service**  
    ```yaml
    services:
      app:
        networks:
          - custom_network
    ```
149. **Set network aliases for a service**  
    ```yaml
    services:
      app:
        networks:
          custom_network:
            aliases:
              - alias1
    ```

---

### **Compose Environment Variables**

150. **Define environment variables in `docker-compose.yml`**  
    ```yaml
    environment:
      - VAR_NAME=value
    ```
151. **Use an external `.env` file**  
    ```bash
    docker-compose --env-file=<file-path> up
    ```
152. **Access environment variables from the host**  
    ```yaml
    environment:
      - HOST_VAR=${HOST_VAR}
    ```

---

### **Compose Volume Management**

153. **Create named volumes in Compose**  
    ```yaml
    volumes:
      data_volume:
    ```
154. **Mount a volume in a service**  
    ```yaml
    services:
      app:
        volumes:
          - data_volume:/path
    ```
155. **Set volume options**  
    ```yaml
    volumes:
      data_volume:
        driver: local
        driver_opts:
          type: tmpfs
          device: tmpfs
    ```

---

### **Compose Debugging**

156. **Run Compose in debug mode**  
    ```bash
    docker-compose --verbose up
    ```
157. **View service logs in real-time**  
    ```bash
    docker-compose logs -f <service-name>
    ```
158. **Run a specific service interactively**  
    ```bash
    docker-compose run <service-name>
    ```

---

### **Docker Registry**

159. **Pull image from private registry**  
    ```bash
    docker pull <registry>/<image-name>:<tag>
    ```
160. **Push image to private registry**  
    ```bash
    docker push <registry>/<image-name>:<tag>
    ```
161. **Login to private registry**  
    ```bash
    docker login <registry>
    ```
162. **Run a private registry locally**  
    ```bash
    docker run -d -p 5000:5000 --name registry registry:2
    ```

---

### **Storage Drivers**

163. **List supported storage drivers**  
    ```bash
    docker info | grep "Storage Driver"
    ```
164. **Change default storage driver**  
    ```bash
    dockerd --storage-driver=<driver-name>
    ```
Here’s the continuation of the **Docker and Docker Compose cheat sheet**, expanding it to include **250 commands** as requested.

---

### **Compose Scaling and Management**

165. **Scale a service to multiple containers**  
    ```bash
    docker-compose up --scale <service-name>=<count>
    ```
166. **Restart a specific service in Compose**  
    ```bash
    docker-compose restart <service-name>
    ```
167. **Stop all Compose services**  
    ```bash
    docker-compose down
    ```
168. **Remove all stopped Compose services and volumes**  
    ```bash
    docker-compose down --volumes
    ```
169. **Force recreate all containers**  
    ```bash
    docker-compose up --force-recreate
    ```
170. **View all running Compose containers**  
    ```bash
    docker-compose ps
    ```

---

### **Security**

171. **Run a container as a non-root user**  
    ```bash
    docker run -u <user-id>:<group-id> <image-name>
    ```
172. **Enable seccomp for a container**  
    ```bash
    docker run --security-opt seccomp=<profile.json> <image-name>
    ```
173. **Enable AppArmor for a container**  
    ```bash
    docker run --security-opt apparmor=<profile-name> <image-name>
    ```
174. **Scan an image for vulnerabilities**  
    ```bash
    docker scan <image-name>
    ```
175. **Add capabilities to a container**  
    ```bash
    docker run --cap-add=<capability> <image-name>
    ```
176. **Drop capabilities from a container**  
    ```bash
    docker run --cap-drop=<capability> <image-name>
    ```

---

### **Container Logs**

177. **Fetch logs of a container**  
    ```bash
    docker logs <container-id>
    ```
178. **Tail logs of a container in real-time**  
    ```bash
    docker logs -f <container-id>
    ```
179. **Limit number of log lines**  
    ```bash
    docker logs --tail <count> <container-id>
    ```
180. **Show timestamps in logs**  
    ```bash
    docker logs --timestamps <container-id>
    ```

---

### **Resource Management**

181. **Limit CPU usage for a container**  
    ```bash
    docker run --cpus="<number>" <image-name>
    ```
182. **Limit memory usage for a container**  
    ```bash
    docker run --memory="<value>" <image-name>
    ```
183. **Set container memory swap limit**  
    ```bash
    docker run --memory-swap="<value>" <image-name>
    ```
184. **View resource usage of running containers**  
    ```bash
    docker stats
    ```

---

### **Export and Import**

185. **Export container file system**  
    ```bash
    docker export <container-id> > <file.tar>
    ```
186. **Import container file system as an image**  
    ```bash
    docker import <file.tar> <image-name>:<tag>
    ```
187. **Save an image to a tar file**  
    ```bash
    docker save -o <file.tar> <image-name>
    ```
188. **Load an image from a tar file**  
    ```bash
    docker load -i <file.tar>
    ```

---

### **Advanced Docker Compose**

189. **Run multiple Compose files**  
    ```bash
    docker-compose -f <file1.yml> -f <file2.yml> up
    ```
190. **Use profiles in Compose**  
    ```yaml
    profiles:
      - profile_name
    ```
191. **Run a service in a specific profile**  
    ```bash
    docker-compose --profile <profile-name> up
    ```
192. **Debug service dependencies**  
    ```yaml
    depends_on:
      - service_name
    ```

---

### **Docker Daemon Management**

193. **View Docker daemon configuration**  
    ```bash
    docker info
    ```
194. **Reload Docker daemon after changes**  
    ```bash
    sudo systemctl reload docker
    ```
195. **Restart Docker daemon**  
    ```bash
    sudo systemctl restart docker
    ```
196. **Start Docker daemon on boot**  
    ```bash
    sudo systemctl enable docker
    ```

---

### **Plugins**

197. **List installed plugins**  
    ```bash
    docker plugin ls
    ```
198. **Install a plugin**  
    ```bash
    docker plugin install <plugin-name>
    ```
199. **Enable a plugin**  
    ```bash
    docker plugin enable <plugin-name>
    ```
200. **Remove a plugin**  
    ```bash
    docker plugin rm <plugin-name>
    ```

---

### **Swarm Mode**

201. **Initialize Docker Swarm**  
    ```bash
    docker swarm init
    ```
202. **Join a Swarm as a worker**  
    ```bash
    docker swarm join --token <token> <manager-ip>:<port>
    ```
203. **List all nodes in a Swarm**  
    ```bash
    docker node ls
    ```
204. **Deploy a stack in Swarm mode**  
    ```bash
    docker stack deploy -c <compose-file> <stack-name>
    ```
205. **List services in a stack**  
    ```bash
    docker stack services <stack-name>
    ```

---

### **Troubleshooting**

206. **Debug container networking**  
    ```bash
    docker network inspect <network-name>
    ```
207. **View container events**  
    ```bash
    docker events
    ```
208. **Debug Docker Daemon logs**  
    ```bash
    journalctl -u docker
    ```

---

### **Miscellaneous**

209. **Show container disk usage**  
    ```bash
    docker system df
    ```
210. **Enable experimental features**  
    ```bash
    dockerd --experimental
    ```
211. **Remove dangling build cache**  
    ```bash
    docker builder prune --filter <filter>
    ```

---

### **Docker Compose File Examples**

212. **Basic Compose file structure**  
    ```yaml
    version: '3.8'
    services:
      app:
        image: nginx
    ```

213. **Compose file with environment variables**  
    ```yaml
    version: '3.8'
    services:
      app:
        image: nginx
        environment:
          - VAR_NAME=value
    ```

214. **Compose file with volume mounting**  
    ```yaml
    version: '3.8'
    services:
      app:
        image: nginx
        volumes:
          - ./data:/var/www
    ```

---

