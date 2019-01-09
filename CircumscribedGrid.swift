//
//  CircumscribedGrid.swift
//  AerialScan
//
//  Created by Ramsundar Shandilya on 1/23/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation
import CoreLocation

struct CircumscribedGrid {
    
    private static let maximumNumberOfLines = 300
    
    private var gridLowerLeft: CLLocationCoordinate2D
    private var extrapolatedDiagonal: Double
    private var angle: Double
    
    init(polygon: Polygon, angle: Double) {
        self.angle = angle
        
        let polygonBounds = polygon.polygonBounds
        
        gridLowerLeft = CLLocationCoordinate2D(origin: polygonBounds.midPoint, distance: polygonBounds.diagonalLength, bearing: angle + 225)
        extrapolatedDiagonal = polygonBounds.diagonalLength * 1.5
    }
    
    func drawGrid(lineDistance: CLLocationDistance) -> [Line] {
        var gridLines: [Line] = []
        
        var numberOfLines = 0
        var startPoint = gridLowerLeft
        
        repeat {
            guard Double(numberOfLines) * lineDistance < extrapolatedDiagonal else {
                break
            }
            
            let endPoint = CLLocationCoordinate2D(origin: startPoint, distance: extrapolatedDiagonal, bearing: angle )
            let line = Line(startPoint: startPoint, endPoint: endPoint)
            gridLines.append(line)
            startPoint = CLLocationCoordinate2D(origin: startPoint, distance: lineDistance, bearing: angle + 90)
            
            numberOfLines += 1
            
        } while numberOfLines <= 300
        
        return gridLines
    }    
}
