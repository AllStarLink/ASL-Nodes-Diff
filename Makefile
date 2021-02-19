NAME = asl-nodes-diff

deb:
	cp update-node-list*.sh deb/asl-update-node-list_2.0.0-beta.4/usr/local/sbin
	cp update-node-list.service deb/asl-update-node-list_2.0.0-beta.4/etc/systemd/system
	cd deb
	dpkg --build asl-update-node-list_2.0.0-beta.4

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
