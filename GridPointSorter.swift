//
//  GridPointSorter.swift
//  AerialScan
//
//  Created by Ramsundar Shandilya on 1/30/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation
import CoreLocation

struct GridPointSorter {
    
    let gridLines: [Line]
    let frontLapDistance: CLLocationDistance
    let obliqueDistance: CLLocationDistance
    
    var flightLinePoints = [CLLocationCoordinate2D]()
    var waypoints = [CLLocationCoordinate2D]()
    var cornerPoints = [CLLocationCoordinate2D]()
    
    
    init(gridLines: [Line], frontLapDistance: CLLocationDistance, obliqueDistance: CLLocationDistance) {
        self.gridLines = gridLines
        self.frontLapDistance = frontLapDistance
        self.obliqueDistance = obliqueDistance
    }
    
    mutating func sortGrid(origin: CLLocationCoordinate2D) {
        var lastPoint = origin
        var tempGridLines = gridLines
        
        var closestLine: Line
        
        while tempGridLines.count > 0 {
            closestLine = nearestLine(from: lastPoint, lines: tempGridLines)
            
            if let index = tempGridLines.index(of: closestLine) {
                tempGridLines.remove(at: index)
            }
            
            let flightLineStartPoint = closestLine.nearestEndpoint(from: lastPoint)
            let flightLineEndPoint = closestLine.farthestEndpoint(from: lastPoint)
            
            flightLinePoints.append(flightLineStartPoint)
            flightLinePoints.append(flightLineEndPoint)
            
            let flightLine = Line(startPoint: flightLineStartPoint, endPoint: flightLineEndPoint)
            let currentWaypointLocations = waypointLocations(for: flightLine, with: frontLapDistance)
            waypoints += currentWaypointLocations
            
            cornerPoints += [currentWaypointLocations.first!, currentWaypointLocations.last!]
            
            lastPoint = flightLineEndPoint            
        }
    }
    
    private func waypointLocations(for flightLine: Line, with frontLapDistance: CLLocationDistance) -> [CLLocationCoordinate2D] {
        var waypoints = [CLLocationCoordinate2D]()
        let numberOfExternalShots = 2
        
        let flightLineLength = flightLine.length
        let bearing = flightLine.heading
        let origin = CLLocationCoordinate2D(origin: flightLine.startPoint, distance: obliqueDistance * Double(numberOfExternalShots), bearing: (bearing + 180).truncatingRemainder(dividingBy: 360))
        waypoints.append(origin)
        
        
        var converedDistance: CLLocationDistance = frontLapDistance
    
        while converedDistance < (flightLineLength + Double(2 * numberOfExternalShots) * obliqueDistance){
            
            let point = CLLocationCoordinate2D(origin: origin, distance: converedDistance, bearing: bearing)
            waypoints.append(point)
            
            converedDistance += frontLapDistance
        }
        
//        waypoints.append(flightLine.endPoint)
        
        return waypoints
    }
    
    
}

