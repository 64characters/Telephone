//
//  UserAgentObserverCompositeTests.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import XCTest

class UserAgentObserverCompositeTests: XCTestCase {

    var composite: UserAgentObserverComposite!
    var observer1: UserAgentObserverSpy!
    var observer2: UserAgentObserverSpy!

    override func setUp() {
        super.setUp()
        composite = UserAgentObserverComposite()
        observer1 = UserAgentObserverSpy()
        observer2 = UserAgentObserverSpy()
        composite.addObserver(observer1)
        composite.addObserver(observer2)
    }

    func testCanAddObservers() {
        XCTAssertTrue(composite[0] === observer1)
        XCTAssertTrue(composite[1] === observer2)
    }

    func testCanRemoveObservers() {
        composite.removeObserver(observer1)

        XCTAssertTrue(composite[0] === observer2)
    }

    func testCallsUserAgentDidFinishStartingOnAllChildren() {
        composite.userAgentDidFinishStarting()

        XCTAssertTrue(observer1.didCallUserAgentDidFinishStarting)
        XCTAssertTrue(observer2.didCallUserAgentDidFinishStarting)
    }
}
