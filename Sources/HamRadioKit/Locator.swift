//
//  Locator.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 27.05.22.
//

import Foundation

#if canImport(CoreLocation)
import CoreLocation
#endif
#if canImport(MapKit)
import MapKit
#endif

public typealias Locator = String

public extension Locator {
    private static let regex = #/^[A-R][A-R]((?![A-X])([0-9][0-9])([A-X][A-X])?){0,2}$/#.ignoresCase()

    var isValid: Bool {
        return (try? Locator.regex.firstMatch(in: self)) != nil
    }

    init(latitude: Double, longitude: Double, precision: Int = 6) {
        var longitude = longitude + 180.0
        var latitude = latitude + 90.0
        self = ""

        self.append(String(UnicodeScalar(65 + Int(longitude / 20.0))!))
        self.append(String(UnicodeScalar(65 + Int(latitude / 10.0))!))

        longitude = fmod(longitude, 20.0)
        latitude = fmod(latitude, 10.0)

        self.append(String(UnicodeScalar(48 + Int(longitude / 2.0))!))
        self.append(String(UnicodeScalar(48 + Int(latitude / 1.0))!))

        if precision <= 4 { return }

        longitude = fmod(longitude, 2.0)
        latitude = fmod(latitude, 1.0)

        self.append(String(UnicodeScalar(65 + Int(longitude * 60.0 / 5.0))!))
        self.append(String(UnicodeScalar(65 + Int(latitude * 60.0 / 2.5))!))
    }

    #if canImport(CoreLocation)
    init(from location: CLLocation, precision: Int = 6) {
        self.init(from: location.coordinate, precision: precision)
    }

    init(from coordinate: CLLocationCoordinate2D, precision: Int = 6) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude, precision: precision)
    }

    func distance(from other: Locator) -> CLLocationDistance? {
        if let thisLocation = self.centerLocation {
            if let otherLocation = other.centerLocation {
                return thisLocation.distance(from: otherLocation)
            }
        }
        return nil
    }

    var coordinate: CLLocationCoordinate2D? {
        guard isValid else { return nil }

        let bytes: [UInt8] = Array(self.uppercased().utf8)

        guard bytes.count >= 2 else { return nil }

        var lon = (CLLocationDegrees(bytes[0] - 65) * 20.0) - 180.0
        var lat = (CLLocationDegrees(bytes[1] - 65) * 10.0) - 90.0

        guard bytes.count >= 4 else {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        lon += CLLocationDegrees(bytes[2] - 48) * 2.0
        lat += CLLocationDegrees(bytes[3] - 48) * 1.0

        guard bytes.count >= 6 else {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        lon += CLLocationDegrees(bytes[4] - 65) * 5.0 / 60.0
        lat += CLLocationDegrees(bytes[5] - 65) * 2.5 / 60.0

        guard bytes.count >= 8 else {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        lon += CLLocationDegrees(bytes[6] - 48) * 0.5 / 60.0
        lat += CLLocationDegrees(bytes[7] - 48) * 0.25 / 60.0

        guard bytes.count >= 10 else {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        lon += CLLocationDegrees(bytes[8] - 65) * (0.5 / 24.0) / 60.0
        lat += CLLocationDegrees(bytes[9] - 65) * (0.25 / 24.0) / 60.0

        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var center: CLLocationCoordinate2D? {
        guard var coordinate = coordinate else { return nil }

        coordinate.latitude += precision.latitude / 2
        coordinate.longitude += precision.longitude / 2

        return coordinate
    }

    var precision: (latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        switch self.count {
        case 2:
            return (10.0, 20.0)
        case 4:
            return (1.0, 2.0)
        case 6:
            return (2.5 / 60.0, 5.0 / 60.0)
        case 8:
            return (0.25 / 60.0, 0.5 / 60.0)
        case 10:
            return ((0.25 / 24.0) / 60.0, (0.5 / 24.0) / 60.0)
        default:
            return (0, 0)
        }
    }

    var centerLocation: CLLocation? {
        guard let center = self.center else { return nil }

        return CLLocation(latitude: center.latitude, longitude: center.longitude)
    }

    var polygon: [CLLocationCoordinate2D]? {
        guard let coordinate = self.coordinate else { return nil }

        return [
            CLLocationCoordinate2D(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            ),
            CLLocationCoordinate2D(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude + precision.longitude
            ),
            CLLocationCoordinate2D(
                latitude: coordinate.latitude + precision.latitude,
                longitude: coordinate.longitude + precision.longitude
            ),
            CLLocationCoordinate2D(
                latitude: coordinate.latitude + precision.latitude,
                longitude: coordinate.longitude
            )
        ]
    }
    #endif

    #if canImport(MapKit)
    var region: MKCoordinateRegion? {
        guard let center = self.center else { return nil }
        
        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(
                latitudeDelta: precision.latitude*1.5,
                longitudeDelta: precision.longitude*1.5
            )
        )
    }
    #endif
}

extension Locator: Identifiable {
    public var id: String {
        self.uppercased()
    }
}
