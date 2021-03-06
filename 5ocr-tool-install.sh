#!/bin/bash
#This tool must be run with sudo and it will help set up 5ocr-tool dependencies


install_curl() {
	echo "Installing curl"
	${pkg_cmd} -qq install curl
}
install_wget() {
	echo "Installing wget"
	${pkg_cmd} -qq install wget
}
install_unzip() {
	echo "Installing unzip"
	${pkg_cmd} -qq install unzip
}
install_aws() {
	echo "Installing awscli"
	tmpdir=`mktemp -d`
	pushd ${tmpdir}
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
	unzip awscliv2.zip
	./aws/install
	popd
	rm -rf ${tmpdir}
}
install_jq() {
	echo "Installing jq"
	${pkg_cmd} -qq install jq
}
install_psql() {
	echo "Installing postgresql client"
	${pkg_cmd} -qq install postgresql-client
}
install_git-remote-codecommit() {
	echo "Installing git-remote-codecommit"
	sudo -u ${SUDO_USER} ${pip_cmd} install --user git-remote-codecommit
}

install_session_manager() {
	echo "Installing the AWS CLI session manager plugin"
	tmpdir=`mktemp -d`
	if [ ${system} = "debian" ]; then
		curl -s ${session_mgr_pkg} -o ${tmpdir}/session-manager-plugin
		dpkg -i ${tmpdir}/session-manager-plugin
	else
		curl -s ${session_mgr_pkg} -o ${tmpdir}/session-manager-plugin.rpm
		${pkg_cmd} -qy localinstall ${tmpdir}/session-manager-plugin.rpm
	fi
	rm -rf ${tmpdir}
	hash -r
}

pathadd() {
    if [ -d "$1" ] && [[ ! $PATH =~ (^|:)$1(:|$) ]]; then
        PATH+=:$1
    fi
}

install_saml2aws() {
	current_version=$(curl -Ls https://api.github.com/repos/Versent/saml2aws/releases/latest | \
		grep 'tag_name' | cut -d'v' -f2 | cut -d'"' -f1
	)
	wget -q -c \
		https://github.com/Versent/saml2aws/releases/download/v${current_version}/saml2aws_${current_version}_linux_amd64.tar.gz -O - | 
		tar -xzv -C /usr/local/bin
	chmod u+x /usr/local/bin/saml2aws
	hash -r
}

install_ecs-cli() {
	echo "Installing the ecs-cli tool"
	curl -s -Lo /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest
	chmod 755 /usr/local/bin/ecs-cli
	hash -r
}

export PATH=/usr/local/bin:${PATH}
#Check the os type
. /etc/os-release
if [ $(echo ${ID_LIKE}|cut -d" " -f1) = "debian" ]; then
	pkg_cmd=apt-get
	${pkg_cmd} -qq update
	session_mgr_pkg="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb"
	system=debian
else
	pkg_cmd=yum
	session_mgr_pkg="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm"
	system=redhat
fi

if command -v pip3 &>/dev/null; then
	pip_cmd=pip3
else
	pip_cmd=pip
fi

if ! command -v curl &>/dev/null; then
	install_curl || exit 1
fi
if ! command -v wget &>/dev/null; then
	install_wget || exit 1
fi
if ! command -v unzip &>/dev/null; then
	install_unzip || exit 1
fi
if ! command -v aws &>/dev/null; then
	install_aws || exit 1
fi
if command -v aws && [ $(aws --version|cut -d"/" -f2 |cut -d"." -f1) -eq 1 ] ; then
	install_aws || exit 1
fi
if ! command -v session-manager-plugin &>/dev/null; then
	install_session_manager || exit 1
fi
if ! command -v saml2aws &>/dev/null; then
	install_saml2aws || exit 1
fi

#Configure saml2aws if it has not been configured before
saml2aws_cmd=$(which saml2aws)
sudo -u ${SUDO_USER} ${saml2aws_cmd} configure \
	--idp-provider=KeyCloak \
	--url=https://sso.chartrequest.com/auth/realms/ChartRequest/protocol/saml/clients/amazon-aws \
	--mfa=Auto \
	--profile=default \
	--session-duration=43200 \
	--skip-prompt >/dev/null

if ! command -v ecs-cli &>/dev/null; then
	install_ecs-cli || exit 1
fi
if ! command -v jq &>/dev/null; then
	install_jq || exit 1
fi
if ! command -v psql &>/dev/null; then
	install_psql || exit 1
fi
if ! sudo -u $SUDO_USER ${pip_cmd} list 2>&1 | grep -q git-remote-codecommit; then
	install_git-remote-codecommit || exit 1
fi
if ! command -v 5ocr_tool &>/dev/null; then
	cp -u $(dirname ${0})/5ocr-tool /usr/local/bin || exit 1
	chmod 755 /usr/local/bin/5ocr-tool
fi

#Generate a machine ID to avoid dbus errors
systemd-machine-id-setup
echo "All set! You may now run '5ocr-tool login' to obtain your temporary keys"
