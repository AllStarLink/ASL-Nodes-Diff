#!/bin/bash

curl -s http://nodes1.allstarlink.org/cgi-bin/nodes.pl | head -n 10
echo "######### END NODES1 ##############";
curl -s http://nodes2.allstarlink.org/cgi-bin/nodes.pl | head -n 10
echo "######### END NODES2 ##############";
curl -s http://nodes3.allstarlink.org/cgi-bin/nodes.pl | head -n 10
echo "######### END NODES3 ##############";
curl -s http://nodes4.allstarlink.org/cgi-bin/nodes.pl | head -n 10
echo "######### END NODES4 ##############";
