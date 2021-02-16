NAME = asl-nodes-diff

install:
	chmod 755 update-node-list*.sh
	sudo cp update-node-list*.sh /usr/local/sbin
	sudo cp update-node-list.service /etc/systemd/system
