//
//  EsriGeometryCreateApp.swift
//  EsriGeometryCreate
//
//  Created by Garett Breen on 10/17/23.
//

import ArcGIS
import SwiftUI

@main
struct EsriGeometryCreateApp: App {
    init() {
        ArcGISEnvironment.apiKey = APIKey("")
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
        }
    }
}
