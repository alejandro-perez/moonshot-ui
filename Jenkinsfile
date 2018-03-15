pipeline {
    agent none
    stages {
        stage('debian8') {
            agent {docker 'debian:8'}
            steps {
                sh 'apt-get update'
                sh 'apt-get dist-upgrade'
                sh 'apt-get install -y build-essential automake autoconf libtool autopoint pkg-config libgtk2.0-dev libgee-dev libnewt-dev valac desktop-file-utils libssl-dev libdbus-glib-1-dev libgnome-keyring-dev git dh-autoreconf devscripts'
        		sh 'git clean -df'
                sh 'sh autogen.sh'
                sh './configure'
                sh 'make'
                cleanWs notFailBuild: true
            }
        }
    }
}
