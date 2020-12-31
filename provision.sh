#! /bin/bash
yum install -y ansible git libselinux-python3.x86_64 yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y containerd.io docker-ce docker-ce-cli
usermod -aG docker centos
systemctl enable --now docker
chmod 666 /var/run/docker.sock
# installing pyenv
yum -y install epel-release
yum -y install git gcc zlib-devel bzip2-devel readline-devel sqlite-devel openssl-devel
curl https://pyenv.run | bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bash_profile
exec "$SHELL"
pyenv install 3.8.2
pyenv global 3.8.2