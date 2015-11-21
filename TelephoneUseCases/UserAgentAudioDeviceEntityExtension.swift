//
//  UserAgentAudioDeviceEntityExtension.swift
//  Telephone
//
//  Created by Alexei Kuznetsov on 21.11.15.
//
//

import Softphone

extension Softphone.UserAgentAudioDevice {
    init(device: UserAgentAudioDevice) {
        self.identifier = device.identifier
        self.name = device.name
    }
}
