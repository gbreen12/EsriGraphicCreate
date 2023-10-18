//
//  ContentView.swift
//  EsriGeometryCreate
//
//  Created by Garett Breen on 10/17/23.
//

import ArcGIS
import SwiftUI

enum CreateType {
    case point
    case polyline
    case polygon
}

struct ContentView: View {
    let createdGraphicOverlay = GraphicsOverlay()
    let creatingGraphicOverlay = GraphicsOverlay()
    
    @State private var map = {
        let map = Map(basemapStyle: .arcGISTopographic)
        
        map.initialViewpoint = Viewpoint(latitude: 34.02700, longitude: -118.80500, scale: 72_000)

        return map
    }()
    @State var createType: CreateType? = nil
    @State var points: [Point] = []
    
    var body: some View {
        NavigationView {
            MapView(map: map, graphicsOverlays: [createdGraphicOverlay, creatingGraphicOverlay])
                .onSingleTapGesture { (cgPoint, mapPoint) in
                    guard let createType else {
                        return
                    }
                    
                    switch createType {
                    case .point:
                        createdGraphicOverlay.addGraphic(Graphic(geometry: mapPoint, attributes: [:], symbol: SimpleMarkerSymbol(style: .circle, color: .orange, size: 10.0)))
                    case .polyline:
                        points.append(mapPoint)
                        creatingGraphicOverlay.removeAllGraphics()
                        
                        let polyline = Polyline(points: points)
                        let line = SimpleLineSymbol(style: .dash, color: .red, width: 1)
                        
                        creatingGraphicOverlay.addGraphic(Graphic(geometry: polyline, attributes: [:], symbol: line))
                        break
                    case .polygon:
                        points.append(mapPoint)
                        creatingGraphicOverlay.removeAllGraphics()
                        
                        let polygon = Polygon(points: points)
                        let outline = SimpleLineSymbol(style: .dash, color: .red, width: 1)
                        let symbol = SimpleFillSymbol(style: .solid, color: .red.withAlphaComponent(0.5), outline: outline)
                        
                        creatingGraphicOverlay.addGraphic(Graphic(geometry: polygon, attributes: [:], symbol: symbol))
                        break
                    }
                }
                .navigationTitle("Map")
                .toolbar {
                    toolbarView
                }
        }
    }
    
    @ViewBuilder
    var toolbarView: some View {
        if createType != nil {
            Button("Cancel") {
                createType = nil
                creatingGraphicOverlay.removeAllGraphics()
                points = []
            }
            Button("Save") {
                if let graphic = creatingGraphicOverlay.graphics.first {
                    creatingGraphicOverlay.removeGraphic(graphic)
                    
                    switch createType {
                    case .point:
                        break
                    case .polyline:
                        graphic.symbol = SimpleLineSymbol(style: .solid, color: .blue, width: 1)
                    case .polygon:
                        let outline = SimpleLineSymbol(style: .solid, color: .green, width: 1)
                        graphic.symbol = SimpleFillSymbol(style: .solid, color: .green.withAlphaComponent(0.5), outline: outline)
                    case nil:
                        break
                    }
                    
                    createdGraphicOverlay.addGraphic(graphic)
                }
                createType = nil
                creatingGraphicOverlay.removeAllGraphics()
                points = []
            }
        } else {
            Menu {
                Button("Point") { createType = .point }
                Button("Polyline") { createType = .polyline }
                Button("Polygon") { createType = .polygon }
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

#Preview {
    ContentView()
}
