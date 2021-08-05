#!/bin/bash
#This tool must be run with sudo and it will help set up 5ocr-tool dependencies

apt-get -qq update

install_aws() {
	echo "Installing awscli"
	apt-get -qq install aws
}
install_jq() {
	echo "Installing jq"
	apt-get -qq install jq
}
install_psql() {
	echo "Installing postgresql client"
	apt-get -qq install postgresql-client
}

install_session_manager() {
	echo "Installing the AWS CLI session manager plugin"
	TMPDIR=`mktemp -d`
	curl -s "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o ${TMPDIR}/session-manager-plugin.deb
	dpkg -i ${TMPDIR}/session-manager-plugin.deb
	hash -r
}

pathadd() {
    if [ -d "$1" ] && [[ ! $PATH =~ (^|:)$1(:|$) ]]; then
        PATH+=:$1
    fi
}

install_saml2aws() {
	CURRENT_VERSION=$(curl -Ls https://api.github.com/repos/Versent/saml2aws/releases/latest | grep 'tag_name' | cut -d'v' -f2 | cut -d'"' -f1)
	wget -c https://github.com/Versent/saml2aws/releases/download/v${CURRENT_VERSION}/saml2aws_${CURRENT_VERSION}_linux_amd64.tar.gz -O - | tar -xzv -C /usr/local/bin
	chmod u+x /usr/local/bin/saml2aws
	hash -r
}

install_ecs-cli() {
	echo "Installing the ecs-cli tool"
	curl -Lo /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest
	chmod 755 /usr/local/bin/ecs-cli
	hash -r
}


if ! hash aws &>/dev/null; then
	install_aws || exit 1
fi
if ! hash session-manager-plugin &>/dev/null; then
	install_session_manager || exit 1
fi
if ! hash saml2aws &>/dev/null; then
	install_saml2aws || exit 1
fi
if ! hash ecs-cli &>/dev/null; then
	install_ecs-cli || exit 1
fi
if ! hash jq &>/dev/null; then
	install_jq || exit 1
fi
if ! hash psql &>/dev/null; then
	install_psql || exit 1
fi
if ! hash 5ocr_tool &>/dev/null; then
	cp -u 5ocr-tool /usr/local/bin || exit 1
	chmod 755 /usr/local/bin/5ocr-tool
fi
