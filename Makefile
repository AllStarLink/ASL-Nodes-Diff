NAME = asl-nodes-diff

install:
ifneq ($(shell id -u), 0)
	@echo "Please run as root or privileged user"
	@exit 1
endif
	chmod 755 update-node-list*.sh
	cp update-node-list*.sh /usr/local/sbin
	cp update-node-list.service /etc/systemd/system
	systemctl disable updatenodelist
	systemctl stop updatenodelist
	systemctl enable update-node-list
	systemctl restart update-node-list
