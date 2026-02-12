# Set Proxy
function setproxy() {
    export PROXY=http://10.154.61.3:3128
    export {http,https,ftp}_proxy=$PROXY
    export {HTTP,HTTPS,FTP}_PROXY=$PROXY

    # git
    git config --global http.proxy $PROXY
    git config --global https.proxy $PROXY

    # npm
    npm config set proxy $PROXY

    # gradle
    if [ -f ~/.gradle/gradle.archive.properties ]; then
        mv  ~/.gradle/gradle.archive.properties ~/.gradle/gradle.properties
    fi

    # utile éventuellement quand on est en mode setproxysmart pour ne pas toujours passer par le proxy d'IA
    export no_proxy="localhost,127.0.0.1,10.75.204.14"
}

# Unset Proxy
function unsetproxy() {
    unset {http,https,ftp}_proxy
    unset {HTTP,HTTPS,FTP}_PROXY
    unset {ALL,_}PROXY
    unset PROXY
    unset no_proxy

    # git
    git config --global --unset http.proxy
    git config --global --unset https.proxy

    # npm
    npm config delete proxy

    # gradle
    if [ -f ~/.gradle/gradle.properties ]; then
        mv ~/.gradle/gradle.properties ~/.gradle/gradle.archive.properties
    fi

}

function showproxy() {
  echo "Affichage des paramètres proxy du poste de développement"
  echo "--------------------------------------------------------"

  env | grep PROXY
  env | grep proxy

  echo "git http.proxy :" $(git config --global --get http.proxy)
  echo "git https.proxy :" $(git config --global --get https.proxy)

  echo "npm proxy :" $(npm config get proxy)

  if [ -f  ~/.gradle/gradle.properties ]; then
    echo "gradle proxy"
    echo "------------"
    cat  ~/.gradle/gradle.properties
  else
    echo "gradle proxy (pas de fichier gradle.properties trouvé)"
  fi
}
