pipeline {
  agent any
  environment {
    SOURCE = "tomsquest/docker-radicale"
    TARGET = "parrazam/radicale-with-infcloud"
    MASTER_BRANCH = "master"
    RELEASE_BRANCH = "release/*"
    VERSION = ''
  }
  options {
    skipStagesAfterUnstable()
  }
  stages {
    stage('Configure pipeline for branch type') {
      steps {
        script {
          if (env.BRANCH_NAME.startsWith('release/')) {
            VERSION = (env.BRANCH_NAME).tokenize('/')[1]
          } else if (env.BRANCH_NAME.equals('master')) {
            VERSION = 'latest'
          } else {
            VERSION = 'unstable'
          }
        }
      }
    }
    stage('Delete older images') {
      steps {
        echo "Removing existing images in local..."
        sh "docker images | grep ${TARGET} | tr -s ' ' | cut -d ' ' -f 2 | xargs -I {} docker rmi ${TARGET}:{}"
      }
    }
    stage("Build image") {
      matrix {
        axes {
            axis {
                name 'PLATFORM'
                values 'linux/amd64', 'linux/arm64', 'linux/arm'
            }
        }
        stages {
          stage('Build by platform') {
            options {
              lock( 'synchronous-matrix' )
            }
            steps {
              echo "Building for ${PLATFORM}"
              script {
                stage("Build ${PLATFORM}") {
                  script {
                    SOURCE_IMAGE = SOURCE
                    if (env.BRANCH_NAME.startsWith('release/')) {
                      SOURCE_IMAGE += ":" + VERSION
                    }
                    TARGET_IMAGE = TARGET + ":" + VERSION
                  }
                  echo "Building ${TARGET_IMAGE} image..."
                  sh "docker pull ${SOURCE_IMAGE}"
                  sh "docker buildx build -t ${TARGET_IMAGE} --platform ${PLATFORM} --build-arg VERSION=${VERSION} ."
                }
              }
            }
          }
          stage('Publish images to Docker Hub') {
            when {
              anyOf {
                branch "${MASTER_BRANCH}"
                branch "${RELEASE_BRANCH}"
              }
            }
            steps {
              withCredentials([usernamePassword(credentialsId: 'dockerHub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
                sh "echo ${env.dockerHubPassword} | docker login -u ${env.dockerHubUser} --password-stdin"
                sh "docker image push --all-tags ${TARGET}"
              }
            }
          }
        }
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
