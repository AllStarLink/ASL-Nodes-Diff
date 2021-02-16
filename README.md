# asl-nodes-diff

Client and server for differential node updates from AllStarLink.

## Client Installation
```sudo make install```
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

## License
GPL-3.0 License

(C) 2018-2021 AllStarLink, Inc