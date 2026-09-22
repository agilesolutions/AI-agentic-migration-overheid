pipeline {

    agent any

    options {
        timestamps()
        disableConcurrentBuilds()

        buildDiscarder(
            logRotator(
                numToKeepStr: '20',
                artifactNumToKeepStr: '10'
            )
        )
    }

    environment {

        /*
         * Java / Gradle
         */
        JAVA_TOOL_OPTIONS = '-Xmx2g'

        /*
         * Container registry
         *
         * Override these from Jenkins configuration or
         * Multibranch Pipeline environment if required.
         */
        REGISTRY = 'registry.example.com'
        IMAGE_NAME = 'openshift/springboot-app'

        /*
         * Jenkins credential containing:
         *
         * username
         * password/token
         */
        REGISTRY_CREDENTIALS = 'container-registry'

        /*
         * Image tag.
         *
         * BUILD_NUMBER gives every Jenkins build a unique tag.
         */
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm

                sh '''
                    echo "Branch: ${BRANCH_NAME}"
                    echo "Commit: ${GIT_COMMIT}"

                    chmod +x ./gradlew

                    ./gradlew --version
                '''
            }
        }

        stage('Compile') {
            steps {
                withGradle {
                    sh '''
                        ./gradlew clean compileJava
                    '''
                }
            }
        }

        stage('Test') {
            steps {
                withGradle {
                    sh '''
                        ./gradlew test
                    '''
                }
            }

            post {
                always {
                    junit(
                        testResults: '**/build/test-results/test/TEST-*.xml',
                        allowEmptyResults: false
                    )
                }
            }
        }

        stage('Build') {
            steps {
                withGradle {
                    sh '''
                        ./gradlew build \
                            -x test
                    '''
                }
            }
        }

        stage('Jib Container Image') {
            steps {

                withCredentials([
                    usernamePassword(
                        credentialsId: "${REGISTRY_CREDENTIALS}",
                        usernameVariable: 'REGISTRY_USERNAME',
                        passwordVariable: 'REGISTRY_PASSWORD'
                    )
                ]) {

                    withGradle {

                        sh '''
                            ./gradlew jib \
                                -Djib.to.image=${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} \
                                -Djib.to.auth.username=${REGISTRY_USERNAME} \
                                -Djib.to.auth.password=${REGISTRY_PASSWORD}
                        '''
                    }
                }
            }
        }

        stage('Publish Image Metadata') {
            steps {
                sh '''
                    echo "=========================================="
                    echo "Container image published"
                    echo "=========================================="
                    echo ""
                    echo "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
                    echo ""

                    if [ -f build/jib-image.digest ]; then
                        echo "Image digest:"
                        cat build/jib-image.digest
                    fi

                    echo ""
                '''
            }
        }

        /*
         * Optional GitOps stage.
         *
         * This should normally NOT modify the application
         * source repository directly.
         *
         * Instead, update the GitOps repository containing
         * the FluxCD HelmRelease.
         */
        stage('Update GitOps') {
            when {
                branch 'main'
            }

            steps {
                echo 'GitOps update would be performed here'
            }
        }
    }

    post {

        success {
            echo """
            ==========================================
            BUILD SUCCESSFUL
            ==========================================

            Application : ${IMAGE_NAME}
            Image       : ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
            Build       : ${BUILD_NUMBER}
            Branch      : ${BRANCH_NAME}
            Commit      : ${GIT_COMMIT}

            ==========================================
            """
        }

        failure {
            echo """
            ==========================================
            BUILD FAILED
            ==========================================

            Application : ${IMAGE_NAME}
            Build       : ${BUILD_NUMBER}
            Branch      : ${BRANCH_NAME}

            ==========================================
            """
        }

        always {
            archiveArtifacts(
                artifacts: 'build/libs/*.jar',
                allowEmptyArchive: true
            )
        }
    }
}