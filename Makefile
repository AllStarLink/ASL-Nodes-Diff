NAME = asl-nodes-diff

install:
	chmod 755 update-node-list*.sh
	sudo cp update-node-list*.sh /usr/local/sbin
	sudo cp update-node-list.service /etc/systemd/system
	sudo systemctl disable updatenodelist
	sudo systemctl stop updatenodelist
	sudo systemctl enable update-node-list
	sudo systemctl start update-node-list
