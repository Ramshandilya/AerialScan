//
//  AerialScanBuilder.swift
//  AerialScan
//
//  Created by Ramsundar Shandilya on 1/23/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation
import CoreLocation

struct AerialScanPlan {
    let flightLinePoints: [CLLocationCoordinate2D]
    let waypoints: [CLLocationCoordinate2D]
    let cornerPoints: [CLLocationCoordinate2D]
}

struct AerialScanBuilder {
    
    let polygon: Polygon
    let aerialScanFlight: AerialScanFlight
    
    func generatePlan() -> AerialScanPlan {
        let circumscribedGrid = CircumscribedGrid(polygon: polygon, angle: aerialScanFlight.sweepAngle)
        let gridLines = circumscribedGrid.drawGrid(lineDistance: aerialScanFlight.sideLapDistance)
        let trimmedGridLines = trim(gridLines: gridLines, polygon: polygon)
        
        var gridSorter = GridPointSorter(gridLines: trimmedGridLines, frontLapDistance: aerialScanFlight.frontLapDistance, obliqueDistance: aerialScanFlight.obliqueDistance)
        gridSorter.sortGrid(origin: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        
        let plan = AerialScanPlan(flightLinePoints: gridSorter.flightLinePoints, waypoints: gridSorter.waypoints, cornerPoints: gridSorter.cornerPoints)
        return plan
    }
}

extension AerialScanBuilder {
    
    func trim(gridLines: [Line], polygon: Polygon) -> [Line] {
        var trimmedGridLines = [Line]()
        for gridLine in gridLines {
            
            var crossings = [CLLocationCoordinate2D]()
            
            let edges = polygon.edges
            for edge in edges {
                guard let intersectionPoint = intersection(line1: edge, line2: gridLine) else {
                    continue
                }
                crossings.append(intersectionPoint)
            }
            
            switch crossings.count {
            case 0,1:
                break
            case 2:
                trimmedGridLines.append(Line(startPoint: crossings[0], endPoint: crossings[1]))
            default:
                let line = externalPoints(from: crossings)
                trimmedGridLines.append(line)
            }
        }
        return trimmedGridLines
    }
}



func waypointsGPX(trackName: String, waypoints: [CLLocationCoordinate2D]) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    let dateAndTime = dateFormatter.string(from: Date())
    
    var gpx = """
    <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
    
    <gpx xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" creator="Oregon 400t" version="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd">
    <metadata>
    <link href="http://www.garmin.com">
    <text>Garmin International</text>
    </link>
    <time>\(dateAndTime)</time>
    </metadata>
    <trk>
    <name>\(trackName)</name>
    <trkseg>
    
    """
    
    waypoints.forEach {
        gpx += """
        <trkpt lat="\($0.latitude)" lon="\($0.longitude)">
        <time>2017-10-27T18:37:26Z</time>
        </trkpt>\n
        """
    }
    
    gpx += """
    </trkseg>
    </trk>
    </gpx>
    """
    
    return gpx
}
