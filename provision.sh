#! /bin/bash
yum install -y git libselinux-python3.x86_64 yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y containerd.io docker-ce docker-ce-cli
usermod -aG docker centos
systemctl enable --now docker
chmod 666 /var/run/docker.sock
# installing pyenv
yum -y install epel-release
yum -y install gcc zlib-devel bzip2-devel readline-devel sqlite-devel openssl-devel
runuser -l centos -c "curl https://pyenv.run | bash"
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~centos/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~centos/.bashrc
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~centos/.bashrc

runuser -l centos -c 'pyenv install 3.8.2'
runuser -l centos -c 'pyenv global 3.8.2'