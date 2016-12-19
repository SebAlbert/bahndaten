module namespace page = 'http://basex.org/examples/web-page';
declare default element namespace "urn:x-inspire:specification:gmlas:RailwayTransportNetwork:3.0";
(: declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization"; :)
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace net = "urn:x-inspire:specification:gmlas:Network:3.2";
declare namespace gml = "http://www.opengis.net/gml/3.2";
declare namespace base = "urn:x-inspire:specification:gmlas:BaseTypes:3.2";

declare
    %rest:path("bahndata-element/{$el}")
    %output:method("json")
    %output:json("format=direct")
    %rest:GET
    function page:bahndata-element($el) {
        let $e := db:open('dev')//*[@gml:id=$el][1]
        return
            <json type="object">
                <xml>{ serialize($e) }</xml>
                <geojson type="array">
                {
                    for $l in $e//gml:LineString
                    return
                        <_ type="object">
                            <type>Feature</type>
                            <geometry type="object">
                                <type>LineString</type>
                                <coordinates type="array">
                                {
                                    for-each-pair(
                                        for-each-pair(
                                            tokenize($l/gml:posList/text()),
                                            1 to 10000,
                                            function($a, $b) { if ($b mod 2 = 1) then $a else () }
                                        ),
                                        for-each-pair(
                                            tokenize($l/gml:posList/text()),
                                            1 to 10000,
                                            function($a, $b) { if ($b mod 2 = 0) then $a else () }
                                        ),
                                        function($a, $b) { <_ type="array"><_>{$b}</_><_>{$a}</_></_> }
                                    )
                                }
                                </coordinates>
                            </geometry>
                            <properties type="object">
                                <name>{ $e/net:inspireId/base:Identifier/base:localId/text() }</name>
                            </properties>
                        </_>
                }
                {
                    for $p in $e//gml:Point
                    return
                        <_ type="object">
                            <type>Feature</type>
                            <geometry type="object">
                                <type>Point</type>
                                <coordinates type="array">
                                    <_>{substring-after($p/gml:pos, ' ')}</_>
                                    <_>{substring-before($p/gml:pos, ' ')}</_>
                                </coordinates>
                            </geometry>
                            <properties type="object">
                                <name>{ $e/net:inspireId/base:Identifier/base:localId/text() }</name>
                            </properties>
                        </_>

                }
                </geojson>
                <refs type="array">
                {
                    for $r in $e//@xlink:href[contains(., 'urn:x-dbnetze:oid:')]
                    return
                        <_ type="object">
                            <id>{ substring-after($r, 'urn:x-dbnetze:oid:') }</id>
                            <reftype>{ node-name($r/..) }</reftype>
                        </_>
                }
                </refs>
                <invrefs type="array">
                {
                    for $r in db:open('dev')//*[@xlink:href = concat('urn:x-dbnetze:oid:', $el)]
                    let $a := $r/ancestor::*[@gml:id]
                    return
                        <_ type="object">
                            <id>{ $a/@gml:id/data() }</id>
                            <type>{ node-name($a) }</type>
                            <reftype>{ node-name($r) }</reftype>
                            <xml>{ serialize($a) }</xml>
                        </_>
                }
                </invrefs>
            </json>
    };
