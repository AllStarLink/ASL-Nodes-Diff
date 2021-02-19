# asl-nodes-diff

Client and server for differential node updates from AllStarLink.

`update-node-list.sh` replaces `rc.updatenodelist` from ASL 1.01 and earlier. It is a drop-in replacement, but please use the Client Installation instructions below.

## Client Installation
```sudo make install```

or on Debian based systems:

```dpkg -i deb/asl-update-node-list_2.0.0-beta.4.deb```

## Server Installation
* Modify .env to fit environment: 
```
cp .env.example .env
```
* Build and run composer
```
docker-compose build
docker-compose run --rm -w /var/www --no-deps nodes-php74 ./composer.phar install
docker-compose up
```

## Authors
Tim Sawyer, WD6AWP

Rob Vella, KK9ROB

Tom Hayward, KD7LXL

Steve Zingman, N4IRS

## License
GPL-3.0 License

(C) 2018-2021 AllStarLink, Inc
