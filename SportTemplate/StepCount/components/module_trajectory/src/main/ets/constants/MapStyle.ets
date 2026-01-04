import { mapCommon } from '@kit.MapKit';

export class MapStyle {
  static readonly styleWhite: mapCommon.CustomMapStyleOptions = {
    styleContent:
    '[\n' +
      '            {\n' +
      '              "mapFeature": "all",\n' +
      '              "options": "geometry",\n' +
      '              "paint": {\n' +
      '                "color": "#EEF0F3"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "all",\n' +
      '              "options": "labels.text.stroke",\n' +
      '              "paint": {\n' +
      '                "color": "#FFFFFF"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "all",\n' +
      '              "options": "labels.icon",\n' +
      '              "paint": {\n' +
      '                "icon-type": "simple"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "administrative",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#929AA7"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "administrative.country",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#9D9D9D"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "administrative.country",\n' +
      '              "visibility": false,\n' +
      '              "options": "geometry.stroke",\n' +
      '              "paint": {\n' +
      '                "color": "#787272"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "administrative.country",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#3F3F3F"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "administrative.province",\n' +
      '              "options": "geometry",\n' +
      '              "paint": {\n' +
      '                "color": "#7D7D7D"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "administrative.capital",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#3F3F3F"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "administrative.major-city",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#3F3F3F"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "landcover.natural",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#929AA7"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "landcover.parkland",\n' +
      '              "options": "geometry",\n' +
      '              "paint": {\n' +
      '                "color": "#D9E9E2"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "landcover.parkland",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#87AF9E"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "landcover.attraction",\n' +
      '              "options": "geometry",\n' +
      '              "paint": {\n' +
      '                "color": "#D9E9E2"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "landcover.hospital",\n' +
      '              "options": "geometry",\n' +
      '              "paint": {\n' +
      '                "color": "#F4E6E6"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "landcover.hospital",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#D0AFAF"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "landcover.human-made.building",\n' +
      '              "options": "all",\n' +
      '              "visibility": false,\n' +
      '              "paint": {\n' +
      '                "color": "#F8FAFB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "poi",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#8D99A8"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "poi.health-care",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#D0AFAF"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "poi.sports.outdoor",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#87AF9E"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "poi.natural",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#87AF9E"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.highway",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#6F757C"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.highway",\n' +
      '              "options": "geometry.stroke",\n' +
      '              "paint": {\n' +
      '                "color": "#B0BCCD"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.highway.country",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#D1DAE6"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.highway.city",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#D8E0EA"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.national",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#6F757C"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.national",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#E4E8ED"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.national",\n' +
      '              "options": "geometry.stroke",\n' +
      '              "paint": {\n' +
      '                "color": "#C6CFDC"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.province",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#909090"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.province",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#FFFFFF"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.province",\n' +
      '              "options": "geometry.stroke",\n' +
      '              "paint": {\n' +
      '                "color": "#E4E6EC"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.city-arterial",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#AFAFAF"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.city-arterial",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#FFFFFF"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.city-arterial",\n' +
      '              "options": "geometry.stroke",\n' +
      '              "paint": {\n' +
      '                "color": "#E4E6EC"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.minor-road",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#AFAFAF"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.minor-road",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#FFFFFF"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.minor-road",\n' +
      '              "options": "geometry.stroke",\n' +
      '              "paint": {\n' +
      '                "color": "#E4E6EC"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.sidewalk",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#AFAFAF"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.sidewalk",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#E4E7EB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.sidewalk",\n' +
      '              "options": "geometry.stroke",\n' +
      '              "paint": {\n' +
      '                "color": "#D6DBE1"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "landcover.human-made.Pedestrain Overpass",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#F6F6F4"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "landcover.human-made.Divider",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#C8E0D6"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.highway.Urban Express Tunnel",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#A8B0BF"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.highway.Urban Express",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#A8B0BF"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.highway.Urban Express Elevated 1",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#A8B0BF"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.highway.Urban Express Elevated 2",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#A8B0BF"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.highway.Urban Express Elevated 3",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#A8B0BF"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.highway.General National Route Bridge",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#C5C9D1"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.highway.General National Route",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#C5C9D1"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.highway.General National Route Elevated 1",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#C5C9D1"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.highway.General National Route Elevated 2",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#C5C9D1"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.highway.General National Route Elevated 3",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#C5C9D1"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.city-arterial.Main Local Road Tunnel",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#E2E6EB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.city-arterial.Main Local Road Elevated 1",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#E2E6EB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.city-arterial.Main Local Road Elevated 2",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#E2E6EB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.city-arterial.Main Local Road Elevated 3",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#E2E6EB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.city-arterial.Main Local Road",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#E2E6EB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.minor-road.General road Tunnel",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#E2E6EB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.minor-road.General road Bridge",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#E2E6EB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.minor-road.General road Non_Display Interval",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#E2E6EB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.minor-road.General road Elevated 1",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#E2E6EB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.minor-road.General road Elevated 2",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#E2E6EB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.minor-road.General road Elevated 3",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#E2E6EB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.minor-road.General road",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#E2E6EB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.minor-road.Sidewalk Polygon",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#E2E7EB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "road.sidewalk.roadsideline",\n' +
      '              "options": "geometry.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#C9D0DB"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "transit",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#246AB3"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "transit.railway",\n' +
      '              "options": "geometry",\n' +
      '              "paint": {\n' +
      '                "color": "#D8D8D8"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "transit.ferry-line",\n' +
      '              "options": "geometry",\n' +
      '              "paint": {\n' +
      '                "color": "#8DC1E7"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "transit.airport",\n' +
      '              "options": "geometry",\n' +
      '              "paint": {\n' +
      '                "color": "#E8EBF1"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "water",\n' +
      '              "options": "geometry",\n' +
      '              "paint": {\n' +
      '                "color": "#C9DDEC"\n' +
      '              }\n' +
      '            },\n' +
      '            {\n' +
      '              "mapFeature": "water",\n' +
      '              "options": "labels.text.fill",\n' +
      '              "paint": {\n' +
      '                "color": "#80B0D3"\n' +
      '              }\n' +
      '            }\n' +
      '          ]'
  };
}