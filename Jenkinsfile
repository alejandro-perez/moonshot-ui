apipeline {
    agent none
    stages {
        stage('debian7') {
            agent {docker 'debian:7'}
            steps {
                sh '''
                    apt-get -y update
                    apt-get -y dist-upgrade
                    apt-get install -y build-essential automake autoconf libtool autopoint pkg-config libgtk2.0-dev libgee-dev libnewt-dev valac desktop-file-utils libssl-dev libdbus-glib-1-dev libgnome-keyring-dev git dh-autoreconf devscripts
                    git merge origin/debian
                    debchange "Add CLI"
                    autoreconf -fi
                    ./configure
                    make dist
                    mv moonshot-ui-1.0.6.tar.xz ../moonshot-ui_1.0.6.orig.tar.xz
                    debuild -us -uc
                    mkdir build7
                    cp ../*.deb build7'''
                archiveArtifacts 'build7/*.deb'
            }
        }
        stage('debian8') {
            agent {docker 'debian:8'}
            steps {
                sh '''
                    apt-get -y update
                    apt-get -y dist-upgrade
                    apt-get install -y build-essential automake autoconf libtool autopoint pkg-config libgtk2.0-dev libgee-dev libnewt-dev valac desktop-file-utils libssl-dev libdbus-glib-1-dev libgnome-keyring-dev git dh-autoreconf devscripts
                    git merge origin/debian
                    debchange "Add CLI"
                    autoreconf -fi
                    ./configure
                    make dist
                    mv moonshot-ui-1.0.6.tar.xz ../moonshot-ui_1.0.6.orig.tar.xz
                    debuild -us -uc
                    mkdir build8
                    cp ../*.deb build8'''
                archiveArtifacts 'build8/*.deb'
            }
        }
    }
}

