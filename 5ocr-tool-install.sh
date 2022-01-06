#!/bin/bash
#This tool must be run with sudo and it will help set up 5ocr-tool dependencies


install_curl() {
	echo "Installing curl"
	${pkg_cmd} -qq install curl
}
install_curl() {
	echo "Installing wget"
	${pkg_cmd} -qq install wget
}
install_aws() {
	echo "Installing awscli"
	${pkg_cmd} -qq install awscli
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
	sudo -u $SUDO_USER pip install git-remote-codecommit
}

install_session_manager() {
	echo "Installing the AWS CLI session manager plugin"
	tmpdir=`mktemp -d`
	curl -s ${session_mgr_pkg} -o ${tmpdir}/session-manager-plugin
	if [ ${system} = "debian" ]; then
		dpkg -i ${tmpdir}/session-manager-plugin
	else
		yum -qy localinstall ${tmpdir}/session-manager-plugin
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

#Check the os type
. /etc/os-release
if [ $ID_LIKE = "debian" ]; then
	pkg_cmd=apt-get
	${pkg_cmd} -qq update
	session_mgr_pkg="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb"
	system=debian
else
	pkg_cmd=yum
	session_mgr_pkg="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm"
	system=redhat
fi


if ! hash curl &>/dev/null; then
	install_curl || exit 1
fi
if ! hash wget &>/dev/null; then
	install_wget || exit 1
fi
if ! hash aws &>/dev/null; then
	install_aws || exit 1
fi
if ! hash session-manager-plugin &>/dev/null; then
	install_session_manager || exit 1
fi
if ! hash saml2aws &>/dev/null; then
	install_saml2aws || exit 1
fi
#Configure saml2aws if it has not been configured before
#if [ ! -f ~/.saml2aws ]; then
	saml2aws configure \
		--idp-provider=KeyCloak \
		--url=https://sso.chartrequest.com/auth/realms/ChartRequest/protocol/saml/clients/amazon-aws \
		--mfa=Auto \
		--profile=default \
		--session-duration=43200 \
		--skip-prompt >/dev/null
#fi
#saml2aws configure --profile=default --session-duration=43200
if ! hash ecs-cli &>/dev/null; then
	install_ecs-cli || exit 1
fi
if ! hash jq &>/dev/null; then
	install_jq || exit 1
fi
if ! hash psql &>/dev/null; then
	install_psql || exit 1
fi
if ! sudo -u $SUDO_USER pip list 2>&1 | grep -q git-remote-codecommit; then
	install_git-remote-codecommit || exit 1
fi
if ! hash 5ocr_tool &>/dev/null; then
	cp -u 5ocr-tool /usr/local/bin || exit 1
	chmod 755 /usr/local/bin/5ocr-tool
fi

#Generate a machine ID to avoid dbus errors
systemd-machine-id-setup
echo "All set! You may now run '5ocr-tool login' to obtain your temporary keys"
