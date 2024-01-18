//
//  ContentView.swift
//  EsriGeometryCreate
//
//  Created by Garett Breen on 10/17/23.
//

import ArcGIS
import CoreData
import SwiftUI

enum CreateType {
    case point
    case polyline
    case polygon
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GeometryModel.createdOn, ascending: true)],
        animation: .default)
    private var savedGeometries: FetchedResults<GeometryModel>
    
    let createdGraphicOverlay = GraphicsOverlay()
    let creatingGraphicOverlay = GraphicsOverlay()
    var savedGraphics: [Graphic] {
        savedGeometries.compactMap { geometryModel -> Graphic? in
            guard let geometryString = geometryModel.geometryString, let geometry = try? Geometry.fromJSON(geometryString) else {
                return nil
            }
            
            if let point = geometry as? Point {
                return Graphic(geometry: point, attributes: [:], symbol: SimpleMarkerSymbol(style: .circle, color: .red, size: 10.0))
            } else if let polyline = geometry as? Polyline {
                let line = SimpleLineSymbol(style: .solid, color: .blue, width: 1)
                return Graphic(geometry: polyline, attributes: [:], symbol: line)
            } else if let polygon = geometry as? Polygon {
                let outline = SimpleLineSymbol(style: .solid, color: .green, width: 1)
                let symbol = SimpleFillSymbol(style: .solid, color: .green.withAlphaComponent(0.5), outline: outline)
                return Graphic(geometry: polygon, attributes: [:], symbol: symbol)
            }
            
            return nil
        }
    }
    
    @State private var map = {
        let map = Map(basemapStyle: .arcGISTopographic)
        
        map.initialViewpoint = Viewpoint(latitude: 34.02700, longitude: -118.80500, scale: 72_000)

        return map
    }()
    @State var createType: CreateType? = nil
    @State var points: [Point] = []
    
    var body: some View {
        NavigationView {
            MapView(map: map, graphicsOverlays: [GraphicsOverlay(graphics: savedGraphics), createdGraphicOverlay, creatingGraphicOverlay])
                .onSingleTapGesture { (cgPoint, mapPoint) in
                    guard let createType else {
                        return
                    }
                    
                    switch createType {
                    case .point:
                        creatingGraphicOverlay.removeAllGraphics()
                        creatingGraphicOverlay.addGraphic(Graphic(geometry: mapPoint, attributes: [:], symbol: SimpleMarkerSymbol(style: .circle, color: .orange, size: 10.0)))
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
                if let graphic = creatingGraphicOverlay.graphics.first, let geometry = graphic.geometry {
                    creatingGraphicOverlay.removeGraphic(graphic)
                    
                    switch createType {
                    case .point:
                        graphic.symbol = SimpleMarkerSymbol(style: .circle, color: .red, size: 10.0)
                    case .polyline:
                        graphic.symbol = SimpleLineSymbol(style: .solid, color: .blue, width: 1)
                    case .polygon:
                        let outline = SimpleLineSymbol(style: .solid, color: .green, width: 1)
                        graphic.symbol = SimpleFillSymbol(style: .solid, color: .green.withAlphaComponent(0.5), outline: outline)
                    case nil:
                        break
                    }
                    
                    createdGraphicOverlay.addGraphic(graphic)
                    
                    let geometryModel = GeometryModel(context: viewContext)
                    geometryModel.id = UUID()
                    geometryModel.geometryString = geometry.toJSON()
                    geometryModel.createdOn = Date()
                    
                    do {
                        try viewContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
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
