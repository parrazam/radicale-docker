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
            VERSION = ''
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
                values 'linux/amd64', 'linux/arm64', 'linux/arm', 'linux/386'
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
                    TARGET_IMAGE = TARGET
                    if (env.BRANCH_NAME.startsWith('release/')) {
                      SOURCE_IMAGE += ":" + VERSION
                      TARGET_IMAGE += ":" + VERSION
                    } else {
                      TARGET_IMAGE += ":" + VERSION
                    }
                  }
                  echo "Building ${TARGET_IMAGE} image..."
                  sh "docker pull ${SOURCE_IMAGE}"
                  sh "docker buildx build -t ${TARGET_IMAGE} --platform ${PLATFORM} --build-arg VERSION=${PLATFORM.tokenize('/')[1]} ."
                }
              }
            }
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
    stage('Tagging with common version') {
      environment {
        GROUPED_VERSION = "${VERSION}"
      }
      when {
        anyOf {
          branch "${MASTER_BRANCH}"
          branch "${RELEASE_BRANCH}"
        }
      }
      steps {
        script {
          if (VERSION.equals('')) {
            GROUPED_VERSION = 'latest'
          }
          if (env.BRANCH_NAME.startsWith('release/')) {
            VERSION = '.' + (env.BRANCH_NAME).tokenize('/')[1]
          }
          IMAGES = ''
          for (ARCH in ['linux/amd64', 'linux/arm64', 'linux/arm', 'linux/386']) {
            IMAGES += ' -a ' + TARGET + ':' + ARCH.tokenize('/')[1] + VERSION
          }
        }
        echo "${IMAGES}"
        sh "docker manifest create ${TARGET}:${GROUPED_VERSION} ${IMAGES}"
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
