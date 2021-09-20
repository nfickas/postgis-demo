import React, { useState, useRef, useEffect } from 'react';

import Map from 'ol/Map'
import View from 'ol/View'
import TileLayer from 'ol/layer/Tile'
import XYZ from 'ol/source/XYZ'
import {transform} from 'ol/proj';
import MVT from 'ol/format/MVT';
import VectorTile from 'ol/source/VectorTile';
import VectorTileLayer from 'ol/layer/VectorTile';
import VectorSource from 'ol/source/Vector';
import VectorLayer from 'ol/layer/Vector';
import GeoJSON from 'ol/format/GeoJSON';
import Style from 'ol/style/Style';
import Stroke from 'ol/style/Stroke';
import Fill from 'ol/style/Fill';
import Circle from 'ol/style/Circle';

function MapWrapper(props) {

  // set intial state - used to track references to OpenLayers 
  //  objects for use in hooks, event handlers, etc.
  const [ map, setMap ] = useState()
  const [ featuresLayer, setFeaturesLayer ] = useState()
  const [ selectedCoord , setSelectedCoord ] = useState()

  // get ref to div element - OpenLayers will render into this div
  const mapElement = useRef()

  // initialize map on first render - logic formerly put into componentDidMount
  useEffect( () => {

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
            url: process.env.REACT_APP_FEATURESERVER_URL + "/collections/public.fires/items.json?limit=100",
            format: new GeoJSON()
        }),
        style: fireStyle
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
        fireLayer
        
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

  },[])

  return (
    <div ref={mapElement} className="map-container"></div>
  )
}

export default MapWrapper;