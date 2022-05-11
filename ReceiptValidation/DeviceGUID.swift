//
//  DeviceGUID.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
//
//  Telephone is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Telephone is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

import Foundation
import IOKit

struct DeviceGUID {
    let dataValue: Data

    init() {
        dataValue = makeGUID()
    }
}

private func makeGUID() -> Data {
    let iterator = makeIterator()
    guard iterator != 0 else { return Data() }

    var mac = Data()
    var service = IOIteratorNext(iterator)
    while service != 0 {
        var parent: io_object_t = 0
        let status = IORegistryEntryGetParentEntry(service, kIOServicePlane, &parent)
        if status == KERN_SUCCESS {
            mac = (IORegistryEntryCreateCFProperty(parent, "IOMACAddress" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as! CFData) as Data
            IOObjectRelease(parent)
        }
        IOObjectRelease(service)
        service = IOIteratorNext(iterator)
    }

    IOObjectRelease(iterator)

    return mac
}

private func makeIterator() -> io_iterator_t {
    var port: mach_port_t = 0
    var status = IOMasterPort(mach_port_t(MACH_PORT_NULL), &port)
    guard status == KERN_SUCCESS else { return 0 }
    guard let match = IOBSDNameMatching(port, 0, "en0") else { return 0 }
    var iterator: io_iterator_t = 0
    status = IOServiceGetMatchingServices(port, match, &iterator)
    guard status == KERN_SUCCESS else { return 0 }
    return iterator
}
