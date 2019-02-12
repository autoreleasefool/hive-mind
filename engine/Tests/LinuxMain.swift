//
//  LinuxMain.swift
//  HiveMindEngineTests
//
//  Created by Joseph Roque on 2019-02-11.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import XCTest
import HiveMindEngineTests

var tests = [XCTestCaseEntry]()
tests += CollectionExtensionTests.allTests()
XCTMain(tests)