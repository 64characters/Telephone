//
//  SoundPreferencesViewEventTarget.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016-2017 64 Characters
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

@objc protocol SoundPreferencesViewEventTarget {
    @objc(viewShouldReloadData:)
    func shouldReloadData(in view: SoundPreferencesView)

    @objc(viewShouldReloadSoundIO:)
    func shouldReloadSoundIO(in view: SoundPreferencesView)

    @objc(viewDidChangeSoundIOWithInput:output:ringtoneOutput:)
    func didChangeSoundIO(input: String, output: String, ringtoneOutput: String)

    @objc(viewDidChangeRingtoneName:)
    func didChangeRingtoneName(_ name: String)

    @objc(viewWillDisappear:)
    func willDisappear(_ view: SoundPreferencesView)
}
