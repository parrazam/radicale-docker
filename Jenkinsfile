pipeline {
  agent any 
  parameters {
    string(name: 'version', description: 'Version from base image')
  }
  environment {
    SOURCE = "tomsquest/docker-radicale"
    TARGET = "parrazam/radicale-with-infcloud"
    MASTER_BRANCH = "master"
  }
  options {
    skipStagesAfterUnstable()
  }
  stages {
    stage('Delete older images') {
      steps {
        echo "Removing existing images in local..."
        sh "docker images | grep ${TARGET} | tr -s ' ' | cut -d ' ' -f 2 | xargs -I {} docker rmi ${TARGET}:{}"
      }
    }
    stage('Build AMD64 image') {
      steps {
        echo "Building ${TARGET}:amd64${params.version} image..."
        sh "docker pull ${SOURCE}:amd64${params.version}"
        sh "docker buildx build -t ${TARGET}:amd64${params.version} --platform linux/amd64 ."
      }
    }
    stage('Build 386 image') {
      steps {
        echo "Building ${TARGET}:386${params.version} image..."
        sh "docker pull ${SOURCE}:386${params.version}"
        sh "docker buildx build -t ${TARGET}:386${params.version} --platform linux/386 ."
      }
    }
    stage('Build ARM image') {
      steps {
        echo "Building ${TARGET}:arm${params.version} image..."
        sh "docker pull ${SOURCE}:arm${params.version}"
        sh "docker buildx build -t ${TARGET}:arm${params.version} --platform linux/arm/v7 ."
      }
    }
    stage('Build ARM64 image') {
      steps {
        echo "Building ${TARGET}:arm64${params.version} image..."
        sh "docker pull ${SOURCE}:arm64${params.version}"
        sh "docker buildx build -t ${TARGET}:arm64${params.version} --platform linux/arm64 ."
      }
    }
    stage('Publish images to Docker Hub') {
      when {
        branch "${MASTER_BRANCH}"
      }
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerHub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
          sh "echo ${env.dockerHubPassword} | docker login -u ${env.dockerHubUser} --password-stdin"
          sh "docker image push --all-tags ${TARGET}"
        }
      }
    }
    stage('Tagging with common version') {
      environment {
        GROUPED_VERSION = """${sh(
                returnStdout: true,
                script: "if [ \"${params.version}\" != \"\" ]; then echo '${params.version}'; else echo 'latest'; fi"
            )}"""
      }
      when {
        branch "${MASTER_BRANCH}"
      }
      steps {
        sh "docker manifest create ${TARGET}:${GROUPED_VERSION} -a ${TARGET}:amd64${params.version} -a ${TARGET}:386${params.version} -a ${TARGET}:arm${params.version} -a ${TARGET}:arm64${params.version}"
        sh "docker manifest push ${TARGET}:${GROUPED_VERSION}"
      }
    }
  }
  post {
    always {
      echo "Removing existing images in local..."
      sh "docker images | grep ${TARGET} | tr -s ' ' | cut -d ' ' -f 2 | xargs -I {} docker rmi ${TARGET}:{}"
    }
  }
}
