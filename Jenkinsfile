pipeline {
    agent any

    parameters {
        choice(
            name: 'DEPLOY_TARGET',
            choices: ['current-instance', 'all-instances'],
            description: 'Deployment Target'
        )

        booleanParam(
            name: 'RUN_HEALTH_CHECK',
            defaultValue: true,
            description: 'Run Health Check'
        )
    }

    stages {

        stage('Prepare') {
            steps {
                script {
                    env.BRANCH_TYPE =
                        env.BRANCH_NAME.startsWith('feature/') ? 'feature' :
                        env.BRANCH_NAME == 'ec2-development' ? 'development' :
                        env.BRANCH_NAME == 'ec2-staging' ? 'staging' :
                        env.BRANCH_NAME == 'main' ? 'production' : 'other'
                }

                echo "Branch: ${env.BRANCH_NAME}"
                echo "Branch Type: ${env.BRANCH_TYPE}"
                echo "Deploy Target: ${params.DEPLOY_TARGET}"
            }
        }

        stage('Validate Scripts') {
            steps {
                sh '''
                    echo "=== Validating Scripts ==="

                    bash -n ec2-info.sh
                    echo "ec2-info.sh syntax OK"

                    bash -n ec2-health.sh
                    echo "ec2-health.sh syntax OK"
                '''
            }
        }

        stage('Test Scripts') {
            when {
                expression {
                    params.RUN_HEALTH_CHECK == true
                }
            }

            parallel {

                stage('EC2 Info Test') {
                    steps {
                        sh '''
                            chmod +x ec2-info.sh
                            ./ec2-info.sh
                        '''
                    }
                }

                stage('EC2 Health Test') {
                    steps {
                        sh '''
                            chmod +x ec2-health.sh
                            ./ec2-health.sh
                        '''
                    }
                }
            }
        }

        stage('Deploy to Development') {
            when {
                anyOf {
                    branch 'ec2-development'

                    expression {
                        env.BRANCH_NAME.startsWith('feature/')
                    }
                }
            }

            steps {
                echo "Deploying to Development"

                sh '''
                    mkdir -p /var/lib/jenkins/ec2-scripts/dev
                    cp ec2-*.sh /var/lib/jenkins/ec2-scripts/dev/
                    chmod +x /var/lib/jenkins/ec2-scripts/dev/*.sh

                    echo "Development deployment completed"
                '''
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'ec2-staging'
            }

            steps {
                echo "Deploying to Staging"

                sh '''
                    mkdir -p /var/lib/jenkins/ec2-scripts/staging
                    cp ec2-*.sh /var/lib/jenkins/ec2-scripts/staging/
                    chmod +x /var/lib/jenkins/ec2-scripts/staging/*.sh

                    echo "Staging deployment completed"
                '''
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }

            steps {
                input message: 'Deploy to Production Instance?',
                      ok: 'Deploy'

                echo "Deploying to Production"

                sh '''
                    mkdir -p /var/lib/jenkins/ec2-scripts/prod
                    cp ec2-*.sh /var/lib/jenkins/ec2-scripts/prod/
                    chmod +x /var/lib/jenkins/ec2-scripts/prod/*.sh

                    echo "Production deployment completed"
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline completed for branch: ${env.BRANCH_NAME}"

            archiveArtifacts artifacts: 'ec2-*.sh',
                             allowEmptyArchive: true
        }

        success {
            echo "Pipeline succeeded!"
        }

        failure {
            echo "Pipeline failed!"
        }
    }
}