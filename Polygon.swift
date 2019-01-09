//
//  Polygon.swift
//  AerialScan
//
//  Created by Ramsundar Shandilya on 1/23/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation
import CoreLocation

struct Polygon {
    
    struct Bounds {
        var bottomLeftPoint = kCLLocationCoordinate2DInvalid
        var topRightPoint = kCLLocationCoordinate2DInvalid
    }
    
    let vertices: [CLLocationCoordinate2D]
    
    func isValid() -> Bool {
        return vertices.count >= 3
    }
    
    var polygonBounds: Bounds {
        return Bounds(polygonPoints: vertices)
    }
    
    var edges: [Line] {
        var lines: [Line] = []
        
        for (index, vertex) in vertices.enumerated() {
            let endIndex = index == vertices.count - 1 ? 0 : index + 1
            lines.append(Line(startPoint: vertex, endPoint: vertices[endIndex]))
        }
        return lines
    }
}

extension Polygon.Bounds {
    
    init(polygonPoints: [CLLocationCoordinate2D]) {
        for point in polygonPoints {
            
            if bottomLeftPoint.isValid  && topRightPoint.isValid {
                
                //TODO: Revisit this. Might need to club 
                if point.longitude > topRightPoint.longitude {
                    topRightPoint.longitude = point.longitude
                }
                
                if point.latitude > topRightPoint.latitude {
                    topRightPoint.latitude = point.latitude
                }
                
                if point.longitude < bottomLeftPoint.longitude {
                    bottomLeftPoint.longitude = point.longitude
                }
                
                if point.latitude < bottomLeftPoint.latitude {
                    bottomLeftPoint.latitude = point.latitude
                }
                
            } else {
                bottomLeftPoint = point
                topRightPoint = point
            }
        }
    }
    
    var midPoint: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: (topRightPoint.latitude + bottomLeftPoint.latitude)/2, longitude: (topRightPoint.longitude + bottomLeftPoint.longitude)/2)
    }
    
    var diagonalLength: CLLocationDistance {
        return bottomLeftPoint.distance(from: topRightPoint)
    }
}


