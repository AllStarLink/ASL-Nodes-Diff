NAME = asl-nodes-diff

install:
       @if ! [ "$(shell id -u)" = 0 ];then
             @echo "Please run as root or privileged user"
             exit 1
       fi
	chmod 755 update-node-list*.sh
	cp update-node-list*.sh /usr/local/sbin
	cp update-node-list.service /etc/systemd/system
	systemctl disable updatenodelist
	systemctl stop updatenodelist
	systemctl enable update-node-list
	systemctl restart update-node-list
