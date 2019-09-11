#!/usr/bin/env groovy
properties([
	parameters([
        string(defaultValue: "master", description: 'Which Git Branch to clone?', name: 'GIT_BRANCH'),
        string(defaultValue: "java-k8s", description: 'Which Git Repo to clone?', name: 'GIT_APP_REPO'),
        string(defaultValue: "ap-south-1", description: 'Docker ECR region', name: 'REGION'),
        string(defaultValue: "043355153133", description: 'AWS Account Number?', name: 'ACCOUNT'),
        string(defaultValue: "java-k8s", description: 'AWS ECR Repository where built docker images will be pushed.', name: 'ECR_REPO_NAME')
	])
])

try {
stage('Clone Repo'){
    node('master'){
      cleanWs()
      checkout([$class: 'GitSCM', branches: [[name: '*/$GIT_BRANCH']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'git@gitlab.com:anup.dubey/${GIT_APP_REPO}.git']]])
    }
  }

  stage('Build Maven'){
    node('master'){
      withMaven(maven: 'apache-maven3.6'){
       sh "mvn clean package"
      }
    }
  }

  stage('Build Docker Image') {
    node('master'){
      sh "\$(aws ecr get-login --no-include-email --region ${REGION})"
      GIT_COMMIT_ID = sh (
        script: 'git log -1 --pretty=%H',
        returnStdout: true
      ).trim()
      TIMESTAMP = sh (
        script: 'date +%Y%m%d%H%M%S',
        returnStdout: true
      ).trim()
      echo "Git commit id: ${GIT_COMMIT_ID}"
      IMAGETAG="${GIT_COMMIT_ID}-${TIMESTAMP}"
	  sh "docker build -t ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGETAG} ."
      sh "docker push ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGETAG}"
    }
  }

  stage('Remove Pushed Image') {
    node('master'){
    sh "docker rmi -f ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGETAG}"
   }
}

stage('Deploy image') {
  	node('master'){
    	withEnv(["KUBECONFIG=${JENKINS_HOME}/.kube/dev-config","IMAGE=${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGETAG}"]){
        	sh "sed -i 's|IMAGE|${IMAGE}|g' k8s/app/deployment.yaml"
        	sh "kubectl apply -f k8s/app"
        	DEPLOYMENT = sh (
          		script: 'yq r k8s/app/deployment.yaml metadata.name',
          		returnStdout: true
        	).trim()
        	echo "Creating k8s resources and rollout status"
                sh "kubectl rollout status deployment/$DEPLOYMENT"
        	sleep 60
        	AVAILABLE= sh (
          		script: "kubectl get deployment/$DEPLOYMENT | grep -v AVAILABLE | awk '{print \$3}'",
          		returnStdout: true
         	).trim()
        	CURRENT= sh (
          		script: "kubectl get deployment/$DEPLOYMENT | grep -v UP-TO-DATE | awk '{print \$4}'",
          		returnStdout: true
         	).trim()
        	if (AVAILABLE.equals(CURRENT)) {
          		currentBuild.result = "SUCCESS"
          		return
        	} else {
          		error("Deployment Unsuccessful.")
          		currentBuild.result = "FAILURE"
          		return
        	}
      	}
    }
  }
}

catch (err){
  currentBuild.result = "FAILURE"
  throw err
}
