
angular
.module("Karte", ["nemLogging", "ui-leaflet"])
.controller("SimpleMapController", [ '$scope', '$http', 'leafletMapEvents', function($scope, $http, leafletMapEvents) {
    angular.extend($scope, {
        input: {},
        defaults: {
            minZoom: 2,
            maxZoom: 17,
            tileSize: 256,
            tileLayer: 'http://{s}.tiles.openrailwaymap.org/standard/{z}/{x}/{y}.png',
            path: {
                weight: 10,
                color: '#800000',
                opacity: 1
            },
            scrollWheelZoom: true
        },
        layers: {
            baselayers: {
                rail: {
                    name: 'OpenRailwayMap',
                    type: 'xyz',
                    url: 'http://{s}.tiles.openrailwaymap.org/standard/{z}/{x}/{y}.png',
                    layerOptions: {
                        subdomains: ['a', 'b', 'c'],
                        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap contributors</a>, Style: <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA 2.0</a> <a href="http://www.openrailwaymap.org/">OpenRailwayMap</a> and OpenStreetMap',
                        continuousWorld: true
                    }
                },
                osm: {
                    name: 'OpenStreetMap',
                    type: 'xyz',
                    url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    layerOptions: {
                        subdomains: ['a', 'b', 'c'],
                        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
                        continuousWorld: true
                    }
                },
                cycle: {
                    name: 'OpenCycleMap',
                    type: 'xyz',
                    url: 'http://{s}.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png',
                    layerOptions: {
                        subdomains: ['a', 'b', 'c'],
                        attribution: '&copy; <a href="http://www.opencyclemap.org/copyright">OpenCycleMap</a> contributors - &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
                        continuousWorld: true
                    }
                }
            }
        },
        geojson: {
            data: {type: "FeatureCollection", features: []},
            style: {
                weight: 10
            }
        },
        streckeLaden: function() {
            $http.get("/strecke/" + this.input.strecke)
            .then(function(response) {
                angular.extend($scope, { streckenteile: response.data });
                $scope.geojson.data.features = response.data;
            });
        }
    });
    console.log(leafletMapEvents.getAvailableMapEvents());
    $scope.$on("leafletDirectiveGeoJson.mouseover", function(e, t) {
        console.log(e);
        console.log(t);
        if (t.leafletObject)
            $scope.highlight = t.leafletObject.feature.properties.name;
    });
}]);
