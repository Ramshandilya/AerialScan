//
//  AerialScanFlight.swift
//  AerialScan
//
//  Created by Ramsundar Shandilya on 1/19/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation

struct AerialScanFlight {
    
    let altitude: Double
    let sweepAngle: Degrees
    let cameraPitchAngle: Degrees
    let camera = Camera.mavic
    
    /// Front Lap / Forward lap is the amount of image overlap between successive photos along a flight line, i.e. the photos that overlaps within the same flight line. Increasing frontlap has minimal effect on flight duration and can increase your chance of making a successful map.
    let frontLap: Double
    
    /// Side Lap is the the amount of overlap between images from adjacent flight lines, i.e. the percentage of overlap between each leg of flight. Increasing sidelap generally increases your chances of a good quality map.
    let sideLap: Double
    
    var lateralFootPrint: Double {
        return altitude * camera.sensorWidth/camera.focalLength
    }
    
    var longitudinalFootPrint: Double {
        return altitude * camera.sensorHeight/camera.focalLength
    }
    
    var sideLapDistance: Double {
        return lateralFootPrint * (1 - sideLap/100)
    }
    
    var frontLapDistance: Double {
        return longitudinalFootPrint * (1 - frontLap/100)
    }
    
    var obliqueDistance: Double {
        return altitude * tan(cameraPitchAngle)
    }
}

struct Camera {
    /// Focal length of the lens (mm)
    let focalLength: Double
    
    /// Sensor Dimensions: Width (m)
    let sensorWidth: Double
    
    /// Sensor Dimensions: Height (m)
    let sensorHeight: Double
    
    let resolutionWidth: Double
    let resolutionHeight: Double
    
    static let mavic = Camera(focalLength: 3.57, sensorWidth: 6.17, sensorHeight: 3.47, resolutionWidth: 4000, resolutionHeight: 3000)
}


