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
        ArcGISEnvironment.apiKey = APIKey("AAPKac6a3feb405249228dc5f0ec94295b4fjzXLQhtJ-g8xCdYOShcTMWfyYBkxY0nNa4wRkV2k1fhcKOps2yz0oHkhuOvIKc0r")
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
        }
    }
}
