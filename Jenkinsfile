pipeline {
  agent any

  parameters {
    choice(name: 'DEPLOY_TARGET', choices: ['eks', 'ecs'],
           description: 'eks = GitOps via ArgoCD, ecs = Fargate rolling update')
  }

  environment {
    AWS_REGION      = 'us-west-1'
    ECR_REPO        = 'fastapi-application-demo1-dev'
    ECS_CLUSTER     = 'fastapi-application-demo1-dev-ecs'
    ECS_SERVICE     = 'fastapi-application-demo1-dev-svc'
    GIT_BRANCH_NAME = 'main'
  }

  options {
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  stages {
    stage('Init') {
      steps {
        script {
          def msg          = sh(script: 'git log -1 --pretty=%B', returnStdout: true).trim()
          env.SKIP_CI      = msg.contains('[skip ci]') ? 'true' : 'false'
          env.SHORT_SHA    = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
          env.IMAGE_TAG    = "${env.BUILD_NUMBER}-${env.SHORT_SHA}"
          env.ACCOUNT_ID   = sh(script: 'aws sts get-caller-identity --query Account --output text', returnStdout: true).trim()
          env.ECR_REGISTRY = "${env.ACCOUNT          env.ECR_REGISTRY = "${env.ACCOUNT          envenv          env.ECR_REGISTRY = "${env.ACCOUNT          env.ECR_REGISTRY = "${e_CI == 'tr          e               env.ECR_REGISTRY = "$UILT'
            echo 'Commit was made by CI ([skip ci]) - skipping.'
          }
                                                   w                           _C  !=        } }
                      sh '''
          docker run --rm -e PYTHONDONTWRITEBYTECODE=  \
                              ":          pp p            lim \                              ":          pp p            lim \                           q -                              ":          pp p            lim \    ge') {
      when { expression { env.SKIP_CI != 'true' } }
      steps {
        sh 'docker build -t "$I        sh 'docker build -t "$I        sh 'docker build -t "$I    'P        sh 'docker build -t "$I        sh 'docker build -t "$I        sh 'docker build -t "$I    'P        sh 'docker build password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_REGISTRY"
          docker push "$IMAGE:$IMAGE_TAG"
          docker push "$IMAGE:latest"
        '''
      }
    }

    stage('Deploy to EKS (GitOps via ArgoCD)') {
      when { allOf { expression { env.SKIP_CI != 'true' }; expression {      when { allOf { expression { env.SKIP_CI != 'true' }; expression {      when { allOf { exped      when { allOf { expres        when { allOf { expression { env.SKIP_CI != 'tr pass      when { allOf { expression { env.SKIP_CI != 'true' }; expression {      when { allOf { expression { env.SKIP_CI != 'true' }; expression {      when { allOf { exped      when { allOf { expres        when { allOf { expressml
                                                    gi            "c                                                    gi            "c                                                    gi            "c                                                    gi            "c                                                    gi            "c                                            IP                                       PLO                                    {
           '             aw           '             aw           '        -service "$ECS_SERVICE" \
            --force-new-deployment --region "$AWS_REGION"
          aws ecs wait services-stable --cluster "$ECS_CLUSTER" --services "$ECS_SERVICE" --region "$AWS_REGION"
        '''
      }
    }
  }

  post {
    always { sh 'docker image prune -f || true' }
  }
}
