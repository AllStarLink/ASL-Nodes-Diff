<?php


function getNodes($timeout)
{
    /* Gather all registered nodes into $rows
       changed this to select the port rather than UDP port, this allows us to not need to set the UDP port 
       in the server config, but rather use the port the register server sees.  If we can fix how we proxy we can eleminate the join.
       fixing the portal to use null vs ' ' would be a capital idea too.
    */

    // Modified to collect proxy nodes as well. 
    $SQL = "SELECT name,ipaddr,port,udpport,node_remotebase,proxy_ip FROM user_Nodes JOIN user_Servers USING (Config_ID) WHERE Status='Active' AND name <> '' AND (ipaddr IS NOT NULL or ipaddr <> '') AND (regseconds > $timeout OR proxy_ip <> '')";
    $sth = \DB::prepare($SQL);
    $sth->execute();
    $rows = $sth->fetchAll();

    // Rather then use ORDER BY 'name' in the query (which slows it), we use php sort()  
    sort($rows);

    return $rows;
}

function printNodes($rows)
{
    // Loop thru and echo all registered nodes.
    //
    foreach ($rows as $row) {
        if (strlen(trim($row['udpport'])) != 0) {
            $ipport = $row['udpport'];
        } else {
            $ipport = $row['port'];
        }
        $ipaddr = $row['ipaddr'];

        if (!empty($row['proxy_ip'])) {
            $arr = explode(':', $row['proxy_ip']);
            $ipaddr = $arr[0];
            $ipport = !empty($arr[1]) ? $arr[1] : '4569';
        }

        if (!isset($row['GenDate'])) {
            $line = $row['name'].'=radio@'.$ipaddr.':'.$ipport.'/'.$row['name'].','.$ipaddr;
        }

        if (!empty($row['node_remotebase'])) {
            $line .= ',y';
        }

        echo "$line\n";
    }

    echo "\n\n";
}

/**
 *
 */
function alphaOnly($string)
{
    return preg_replace("/[^A-Za-z0-9]+/", "", $string);
}
