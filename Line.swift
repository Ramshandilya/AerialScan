//
//  Line.swift
//  AerialScan
//
//  Created by Ramsundar Shandilya on 1/29/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation
import CoreLocation

struct Line {
    let startPoint: CLLocationCoordinate2D
    let endPoint: CLLocationCoordinate2D
    
    var heading: Degrees {
        let startPointLat = startPoint.latitude.degreesToRadians
        let startPointLong = startPoint.longitude.degreesToRadians
        
        let endPointLat = endPoint.latitude.degreesToRadians
        let endPointLong = endPoint.longitude.degreesToRadians
        
        let angleRadians = atan2(sin(endPointLong - startPointLong) * cos(endPointLat), cos(startPointLat) * sin(endPointLat) - sin(startPointLat) * cos(endPointLat) * cos(endPointLong - startPointLong))
        let angleDegrees = angleRadians.radiansToDegrees
        
        return angleDegrees > 0 ? angleDegrees : 360 + angleDegrees //warp it to positive angle
    }
    
    var length: CLLocationDistance {
        return startPoint.distance(from: endPoint)
    }
    
    func nearestEndpoint(from point: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return (point.distance(from: startPoint) < point.distance(from: endPoint)) ? startPoint : endPoint
    }
    
    func farthestEndpoint(from point: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return (point.distance(from: startPoint) > point.distance(from: endPoint)) ? startPoint : endPoint
    }
}

extension Line: Equatable {
    static public func == (lhs: Line, rhs: Line) -> Bool {
        return lhs.startPoint == rhs.startPoint && lhs.endPoint == rhs.endPoint
    }
}

/// Find the intersecting point of the two lines. Returns `nil` if the lines are parallel.
func intersection(line1: Line, line2: Line) -> CLLocationCoordinate2D? {
    //Using determinants
    
    //Line1 : (x1 y1) --- (x2 y2)
    //Line2 : (x3 y3) --- (x4 y4)
    
    let denominator = (line1.startPoint.latitude - line1.endPoint.latitude) * (line2.startPoint.longitude - line2.endPoint.longitude) - (line1.startPoint.longitude - line1.endPoint.longitude) * (line2.startPoint.latitude - line2.endPoint.latitude)
    
    guard denominator != 0 else {
        return nil
    }
    
    /*
    /*
     | x1 y1 |
     | x2 y2 |
    */
    /// (x1y2 - y1x2)
    let line1Determinant = (line1.startPoint.latitude * line1.endPoint.longitude) - (line1.startPoint.longitude * line1.endPoint.latitude)
    
    /*
     | x3 y3 |
     | x4 y5 |
     */
    /// (x3y4 - y3x4)
    let line2Determinant = (line2.startPoint.latitude * line2.endPoint.longitude) - (line2.startPoint.longitude * line2.endPoint.latitude)
    
    let intersectionLat = (line1Determinant * (line2.startPoint.latitude - line2.endPoint.latitude) - line2Determinant * (line1.startPoint.latitude - line1.endPoint.latitude)) / denominator
    let intersectionLong = (line1Determinant * (line2.startPoint.longitude - line2.endPoint.longitude) - line2Determinant * (line1.startPoint.longitude - line1.endPoint.longitude)) / denominator
    
    return CLLocationCoordinate2D(latitude: intersectionLat, longitude: intersectionLong)
    */
    
    
//    let numerator1 = (line1.startPoint.longitude - line2.startPoint.longitude) * (line2.endPoint.latitude - line2.startPoint.latitude) - (line1.startPoint.latitude - line2.startPoint.latitude) * (line2.endPoint.longitude - line2.startPoint.longitude)
    let numerator1 = (line1.startPoint.longitude - line2.startPoint.longitude) * (line2.endPoint.latitude - line2.startPoint.latitude) - (line1.startPoint.latitude - line2.startPoint.latitude) * (line2.endPoint.longitude - line2.startPoint.longitude)
    let r = numerator1 / denominator
    
    let numerator2 = (line1.startPoint.longitude - line2.startPoint.longitude) * (line1.endPoint.latitude - line1.startPoint.latitude) - (line1.startPoint.latitude - line2.startPoint.latitude) * (line1.endPoint.longitude - line1.startPoint.longitude)
    let s = numerator2 / denominator
    
    //Check if the intersection is within the line segments
    guard r >= 0 && r <= 1 && s >= 0 && s <= 1 else {
        return nil
    }
    
    let intersectionLat = line1.startPoint.latitude + r * (line1.endPoint.latitude - line1.startPoint.latitude)
    let intersectionLong = line1.startPoint.longitude + r * (line1.endPoint.longitude - line1.startPoint.longitude)
    
    return CLLocationCoordinate2D(latitude: intersectionLat, longitude: intersectionLong)
    
}

/// Find the nearest line from a point 
func nearestLine(from point: CLLocationCoordinate2D, lines: [Line]) -> Line {
    let closestLine = lines.min { (line1, line2) -> Bool in
        return line1.nearestEndpoint(from: point).distance(from: point) < line2.nearestEndpoint(from: point).distance(from: point)
    }
    return closestLine!
}

//TODO:cleanup
func externalPoints(from points: [CLLocationCoordinate2D]) -> Line{
    let meanCoord = Polygon(vertices: points).polygonBounds.midPoint
    let start = farthestPoint(from: meanCoord, points: points)
    let end = farthestPoint(from: start, points: points)
    
    return Line(startPoint: start, endPoint: end)
}

func farthestPoint(from origin: CLLocationCoordinate2D, points: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
    let farthest = points.max { (point1, point2) -> Bool in
        return point1.distance(from: origin) < point2.distance(from: origin)
    }
    return farthest!
}
