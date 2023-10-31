#!/usr/bin/env groovy

def newVersion
def localEnv

@NonCPS
static HashMap version(String lastVersion) {
    final String parserRegex = /^(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)/
    java.util.regex.Matcher matcher = lastVersion =~ parserRegex
    if (matcher.matches()) {
        HashMap map = [major:matcher.group('major'), minor:matcher.group('minor'), patch: matcher.group('patch')] as HashMap

        return map
    } else {
        return null
    }
}

pipeline {
    agent any

    options {
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    stages {
        stage('Configure') {
            steps {
                checkout ([
                        $class                           : 'GitSCM',
                        branches                         : scm.branches,
                        doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                        extensions                       : scm.extensions + [[$class: 'LocalBranch']],
                        userRemoteConfigs                : scm.userRemoteConfigs
                ])
                withCredentials([gitUsernamePassword(credentialsId: 'GITHUB_KEY')]) {
                    sh "git fetch --tags 2> /dev/null"
                }
                script {
                    localEnv = load "settings.groovy"
                }
            }
        }

        stage('Prepare build') {
            steps {
                withCredentials([gitUsernamePassword(credentialsId: 'GITHUB_KEY')]) {
                    script {
                        def commitMessage = sh(returnStdout: true, script: "git log --format=%B -n 1").trim()
                        def lastCommitTag = sh(returnStdout: true, script: "git tag --contains HEAD --sort=-creatordate | tail -1").trim()
                        if (lastCommitTag.isEmpty() && commitMessage.contains("[") && commitMessage.contains("]")) {
                            def commitMessagePrefix = commitMessage.substring(commitMessage.indexOf("[") + 1, commitMessage.indexOf("]"))
                            withCredentials([gitUsernamePassword(credentialsId: 'GITHUB_KEY')]) {
                                // String lastVersion = sh(returnStdout: true, script: 'git describe --tags --abbrev=0 2> /dev/null || echo "0.0.0"').trim().toLowerCase().replace(localEnv.GIT_TAG_PREFIX, '')
                                String lastVersion = sh(returnStdout: true, script: 'git describe --tags --abbrev=0 2> /dev/null || echo "0.0.0"').trim().toLowerCase()

                                HashMap currentVersion = version(lastVersion)
                                if (currentVersion) {
                                    major = currentVersion.major
                                    minor = currentVersion.minor
                                    patch = currentVersion.patch
                                } else {
                                    throw new Exception("No find version in string: $lastVersion") as java.lang.Throwable
                                }

                                switch (commitMessagePrefix) {
                                    case "CHANGE":
                                        major = Integer.parseInt(major) + 1
                                        newVersion = "$major.0.0"
                                        break
                                    case "FEATURE":
                                        minor = Integer.parseInt(minor) + 1
                                        newVersion = "$major.$minor.0"
                                        break
                                    case "FIX":
                                        patch = Integer.parseInt(patch) + 1
                                        newVersion = "$major.$minor.$patch"
                                        break
                                    default:
                                        throw new Exception("Cannot release new version. Incorrect commit message: $commitMessagePrefix") as java.lang.Throwable
                                }

                                if (env.BRANCH_NAME != "master") {
                                    NORMALIZED_BRANCH_NAME = "${env.BRANCH_NAME}".replaceAll("[-/]", '').toLowerCase()
                                    newVersion = "${newVersion}-rc-${env.BUILD_NUMBER}-${NORMALIZED_BRANCH_NAME}-SNAPSHOT"
                                }

                                currentBuild.displayName = "#${currentBuild.id} - ${newVersion}"
                            }
                        }
                    }
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    if (env.BRANCH_NAME != "master") {
                        timeout(time: 480, unit: 'MINUTES') {
                            input(message: "Should build image?", ok: "Yes")
                        }
                    }
                }
                script {
                    docker.withRegistry(env.DOCKER_REGISTRY_URL, 'DOCKER_REGISTRY_PASSWORD') {
                        sh(returnStdout: true, script: "echo 'Running building command for version: \'${newVersion}\''")
                        sh "./buildAndDeploy.sh build ${newVersion} ${env.DOCKER_REGISTRY_URL}"
                        sh "docker images"
                    }
                }
            }
        }

        stage('Publish') {
            steps {
                script {
                    if (env.BRANCH_NAME != "master") {
                        timeout(time: 480, unit: 'MINUTES') {
                            input(message: "Should push image to registry?", ok: "Yes")
                        }
                    }
                }
                script {
                    docker.withRegistry(env.DOCKER_REGISTRY_URL, 'DOCKER_REGISTRY_PASSWORD') {
                        sh(returnStdout: true, script: "echo 'Running push command for version: \'${newVersion}\''")
                        sh "./buildAndDeploy.sh push ${newVersion} ${env.DOCKER_REGISTRY_URL}"
                    }
                }
            }
        }
        
        stage('Tag') {
            steps {
                script {
                    withCredentials([gitUsernamePassword(credentialsId: 'GITHUB_KEY')]) {
                        if (env.BRANCH_NAME == 'master') {
                            // sh(returnStdout: true, script: "git tag ${localEnv.GIT_TAG_PREFIX}${newVersion}")
                            sh(returnStdout: true, script: "git tag ${newVersion}")
                            sh(returnStdout: true, script: 'git push --tags')
                        }
                    }
                }
            }
        }
    }
}
