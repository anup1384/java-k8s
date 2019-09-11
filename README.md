# Java and Kubernetes

## Part one - base app:

### Requirements:

**Docker and Make**

### Build and run application:

Spring boot and mysql database running on docker

**Clone from repository**
```bash
git clone https://github.com/anup1384/java-k8s.git
```

**Build application**
```bash
mvn clean install
```

## Part two - app on Docker:

Create a Dockerfile:

```yaml
FROM openjdk:11.0.3-jdk-slim
COPY target/*.jar /var/www/app.jar
EXPOSE 8080
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -jar /var/www/app.jar" ]
```

## Part three - app on Kubernetes:

We have an application and image running in docker
Now, we deploy application in a kunernetes cluster running in our machine

Prepare

### Start minikube
`minikube start`

### Deploy database

`kubectl apply -f k8s/mysql/` create mysql deployment and service

`kubectl get pods`

`kubectl port-forward  <pod_name> 3306:3306`

## Deploy application

`kubectl apply -f k8s/app` create app deployment and service


## Check pods

`kubectl get pods `

Delete pod
`kubectl delete pod -n myapp-f7974h497-82k4r`

Replicas
`kubectl get rs`

Scale
`kubectl scale deployment/myapp --replicas=2`

View replicas
`
while true
do curl "http://minikubeip/hello"
echo
sleep 2
done
`

## Check app url
`minikube service  myapp --url`

Change your IP and PORT as you need it

`curl -X GET http://192.168.99.132:31838/persons`

Add new Person
`curl -X POST http://192.168.99.100:31838/persons -H "Content-Type: application/json" -d '{"name": "New Person", "birthDate": "2000-10-01"}'`

