module namespace page = 'http://basex.org/examples/web-page';
declare default element namespace "urn:x-inspire:specification:gmlas:RailwayTransportNetwork:3.0";
(: declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization"; :)
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace net = "urn:x-inspire:specification:gmlas:Network:3.2";
declare namespace gml = "http://www.opengis.net/gml/3.2";
declare namespace base = "urn:x-inspire:specification:gmlas:BaseTypes:3.2";

declare
    %rest:path("strecke/{$strid}")
    %output:method("json")
    %output:json("format=direct")
    %rest:GET
    function page:strecke($strid) {
        <json type="array">
        {
            for $l in db:open('dev')//*[text()=$strid]/../net:link
            let $m := db:open('dev')//RailwayLink[@gml:id=substring-after($l/@xlink:href, 'urn:x-dbnetze:oid:')]
            return
                <_ type="object">
                    <type>Feature</type>
                    <geometry type="object">
                        <type>LineString</type>
                        <coordinates type="array">
                        {
                            for-each-pair(
                                for-each-pair(
                                    tokenize($m/net:centrelineGeometry/gml:LineString/gml:posList/text()),
                                    1 to 10000,
                                    function($a, $b) { if ($b mod 2 = 1) then $a else () }
                                ),
                                for-each-pair(
                                    tokenize($m/net:centrelineGeometry/gml:LineString/gml:posList/text()),
                                    1 to 10000,
                                    function($a, $b) { if ($b mod 2 = 0) then $a else () }
                                ),
                                function($a, $b) { <_ type="array"><_>{$b}</_><_>{$a}</_></_> }
                            )
                        }
                        </coordinates>
                    </geometry>
                    <properties type="object">
                        <name>{ $m/net:inspireId/base:Identifier/base:localId/text() }</name>
                    </properties>
                </_>
        }
        </json>
    };
