import React, { useState, useRef, useEffect } from 'react';

import { Map, View } from 'ol';
import { Tile as TileLayer, VectorTile as VectorTileLayer, Vector as VectorLayer, Heatmap as HeatmapLayer } from 'ol/layer';
import { Style, Stroke, Fill, Circle } from 'ol/style';
import { MVT, GeoJSON } from 'ol/format';
import { XYZ, VectorTile, Vector as VectorSource } from 'ol/source';
import { transform }  from 'ol/proj';

function MapWrapper(props) {

  // set intial state - used to track references to OpenLayers 
  //  objects for use in hooks, event handlers, etc.
  const [ map, setMap ] = useState()
  const [ featuresLayer, setFeaturesLayer ] = useState()
  const [ fireLayer, setFireLayer ] = useState()
  const [ heatmapLayer, setHeatmapLayer ] = useState()
  const [ fireCount, setFireCount ] = useState(0)

  async function getData() {
    const res = await fetch(process.env.REACT_APP_FEATURESERVER_URL + "/functions/count_fires/items.json");
    const data = await res.json();

    // store the data into our books variable
    setFireCount(data[0].num) ;
  }
  // get ref to div element - OpenLayers will render into this div
  const mapElement = useRef()

  function activateHeatmap() {
    heatmapLayer.setVisible(!heatmapLayer.getVisible());
    fireLayer.setVisible(!fireLayer.getVisible());
  }

  // initialize map on first render - logic formerly put into componentDidMount
  useEffect( () => {
    getData();

    const fireStyle = new Style({
        image: new Circle({
            radius: 5,
            stroke: new Stroke({
                width: 2,
                color: "#eb4034"
            }),
            fill: new Fill({
                color: "#eb4034"
            })
        })
    })

    var vectorStyle = new Style({
        stroke: new Stroke({
          width: 2,
          color: "#ff00ff99"
        }),
        fill: new Fill({
          color: "#ff00ff33"
        })
    });

    // create and add vector source layer
    const initalFeaturesLayer = new VectorTileLayer({
      source: new VectorTile({
          url: process.env.REACT_APP_TILESERVER_URL + "/public.county_boundary/{z}/{x}/{y}.pbf",
          format: new MVT()
        }),
        style: vectorStyle
    })
    
    const fireLayer = new VectorLayer({
        source: new VectorSource({
            url: process.env.REACT_APP_FEATURESERVER_URL + "/collections/public.fires/items.json?limit=100000",
            format: new GeoJSON()
        }),
        style: fireStyle
    })

    const heatmapLayer = new HeatmapLayer({
      source: new VectorSource({
        url: process.env.REACT_APP_FEATURESERVER_URL + "/collections/public.fires/items.json?limit=100000",
        format: new GeoJSON()
      }),
      blur: 10,
      raidus: 10,
      weight: function(feature) {
        return 30;
      },
      visible: false
    })

    // create map
    const initialMap = new Map({
      target: mapElement.current,
      layers: [
        
        // USGS Topo
        new TileLayer({
          source: new XYZ({
            url: 'https://basemap.nationalmap.gov/arcgis/rest/services/USGSTopo/MapServer/tile/{z}/{y}/{x}',
          })
        }),
        initalFeaturesLayer,
        fireLayer,
        heatmapLayer   
      ],
      view: new View({
        center: transform([-122.0168, 37.0483], 'EPSG:4326', 'EPSG:3857'),
        zoom: 11
      }),
      controls: []
    })

    // save map and vector layer references to state
    setMap(initialMap)
    setFeaturesLayer(initalFeaturesLayer)
    setFireLayer(fireLayer)
    setHeatmapLayer(heatmapLayer)

  },[])

  return (
    <div>
        <div ref={mapElement} className="map-container">
        </div>
        <div>
          <b>Number of Fires {fireCount}</b>
        </div>
        <div>
          <button onClick={activateHeatmap}>
            Toggle Heatmap
          </button>
        </div>
    </div>
  )
}

export default MapWrapper;