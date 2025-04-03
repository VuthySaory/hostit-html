pipeline {
    agent any
    environment {
        
        // MAIN Image Manager
        DOCKER_HUB_REPOSITORY = "krolnoeurnrpisb"
        DOCKER_HUB_IMAGE = "image_mediplus"
        DOCKER_CREDENTIALS = "krolnoeurnrpisb_id"
        CONTAINER_NAME = "mediplus_app_1"
        CONTAINER_PORT = "9090"
        GITHUB_REPOSITORY = "https://github.com/krolnoeurn36/mediplus.git"
    
    }
    parameters {
        gitParameter(name: 'TAG', type: 'PT_TAG', defaultValue: '', description: 'Select the Git tag to build.')
        gitParameter(name: 'BRANCH', type: 'PT_BRANCH', defaultValue: '', description: 'Select the Git branch to build.')
          // Parameter for selecting the deployment action
        choice(name: 'ACTION',choices: ['deploy', 'rollback'],description: 'Choose whether to deploy a new version or rollback to a previous version.')
    }
    stages {
        stage('Checkout Code') {
            steps {
                script {
                   try{
                     if (params.TAG) { 
                        echo "Checking out tag: ${params.TAG}"
                        checkout([$class: 'GitSCM',
                            branches: [[name: "refs/tags/${params.TAG}"]],
                            userRemoteConfigs: [[url:env.GITHUB_REPOSITORY]]
                        ])
                      } else {
                          echo "Checking out branch: ${params.BRANCH}"
                          checkout([$class: 'GitSCM',
                              branches: [[name: "${params.BRANCH}"]],
                              userRemoteConfigs: [[url: env.GITHUB_REPOSITORY]]
                          ])
                      }
                   }catch(Exception e) {
                        
                        echo "Error during checkout process : ${e.message }"
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                script {
                  try{
                    if(params.ACTION == "rollback"){
                      //Check Image exists on Docker Hub
                      if(checkExistingImageOnDockerHub("${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}", "${params.TAG}")){
                          echo "Status: ${params.ACTION} => Image ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG} exists on Docker Hub"
                          echo "Status: ${params.ACTION} => Rollback to ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG}"
                          // check image is running or not

                      }else {
                          echo "Status: ${params.ACTION} => Image ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG} not exists on Docker Hub"
                          echo "Status: ${params.ACTION} => Rollback failed to ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG}"
                          currentBuild.result = 'FAILURE'
                          throw e
                      }
                    }else {
                      // check if the image exists on Docker Hub
                      if(checkExistingImageOnDockerHub("${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}", "${params.TAG}")){
                          echo "Status: ${params.ACTION} => Image ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG} exists on Docker Hub. We will not build and push the image."
                          currentBuild.result = 'FAILURE'
                          throw e
                          
                      }else {
                        // Implement your build logic here
                        echo "Status: ${params.ACTION} =>Building from ${env.BRANCH}"
                        echo "Status: ${params.ACTION} =>Building from ${env.BRANCH} and Tag ${env.TAG} to Image:${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG}"
                        // Example build command
                        withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                          sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        }
                        sh """
                          docker build -t ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG} .
                        
                          docker push ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG}
                        """
                        echo "Status: ${params.ACTION} => Build done of ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG} and Push to: ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG} "
                      }  
                    }
                  }catch(Exception e) {
                      
                      echo "Error during checkout process : ${e.message}"
                      currentBuild.result = 'FAILURE'
                      throw e
                  } 
                }
            }
        }
        stage("Remove Old Contianer"){
            steps{
                script{
                    try{
                      
                        // Example command to remove a container
                        echo "Removing old container"
                        def commandWrite = """
                            ssh root@18.204.218.151 /var/scripts/remove_old_container.sh ${env.CONTAINER_NAME}
                        """
                        def status = sh(script: commandWrite, returnStatus: true)
                        if(!status){
                 
                            echo "Status: ${params.ACTION} => Removed old container ${env.CONTAINER_NAME}"
                        }else {
                            currentBuild.result = 'FAILURE'
                            throw e
                        }
                    }catch(Exception e) {
                      
                      echo "Error during checkout process : ${e.message}"
  
                      currentBuild.result = 'FAILURE'
                      throw e
                  }  
                }
            }
        }
        stage("Deploying"){
            steps{
              script{
                  try{
                   
                    
                    def commandWrite= """
                        ssh root@18.204.218.151 /var/scripts/deploy.sh ${env.CONTAINER_NAME} ${env.CONTAINER_PORT} ${env.DOCKER_HUB_REPOSITORY} ${env.DOCKER_HUB_IMAGE} ${params.TAG}
                    """
                    def status = sh(script: commandWrite, returnStatus: true)
                    if(!status){
                        
                        echo "Status: ${params.ACTION} => Deployed ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG} to ${env.CONTAINER_NAME}"
                    }else {
                      currentBuild.result = 'FAILURE'
                      echo "Error during checkout process : ${e.message}"
                      throw e
                    }
                  }catch(Exception e) {
                    //   sendTelegramMessage("Error during checkout process : ${e.message}")
                      echo "Error during checkout process : ${e.message}"
                      currentBuild.result = 'FAILURE'
                      throw e
                  }  
              }
            }
        } 
        stage("Remove Unused Image"){
            steps{
              script{
                  try{
                   
                    
                    def commandWrite= """
                        ssh root@18.204.218.151 /var/scripts/remove_unused_image.sh ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}
                    """
                    def status = sh(script: commandWrite, returnStatus: true)
                    if(!status){
                        
                        echo "All Unused was destroy"
                    }else {
                      currentBuild.result = 'FAILURE'
                      echo "Error during checkout process : ${e.message}"
                      throw e
                    }
                  }catch(Exception e) {
                    //   sendTelegramMessage("Error during checkout process : ${e.message}")
                      echo "Error during checkout process : ${e.message}"
                      currentBuild.result = 'FAILURE'
                      throw e
                  }  
              }
            }
        } 
    }
    post {
         success {
            echo "✅ Build Successful!"
        }
        failure {
            echo "❌ Build Failed!"
        }
        always {
            echo "🔄 This runs no matter what."
        }
    }
}


def checkExistingImageOnDockerHub(imageName, tag) {     
    def imageExists = sh(
        script: """
        curl -s -o /dev/null -w "%{http_code}" https://hub.docker.com/v2/repositories/${imageName}/tags/${tag}/
        """,
        returnStdout: true
    ).trim()
    return imageExists == "200" ? true : false

}
