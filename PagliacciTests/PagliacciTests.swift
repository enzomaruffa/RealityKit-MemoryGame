//
//  PagliacciTests.swift
//  PagliacciTests
//
//  Created by Enzo Maruffa Moreira on 24/01/20.
//  Copyright © 2020 Enzo Maruffa Moreira. All rights reserved.
//

import XCTest
@testable import Pagliacci

class PagliacciTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCardStartsHidden() {
        let card = Card(name: "test", assetName: "test", text: "test", shortText: "test", meta: false)
        XCTAssertEqual(card.revealed, false, "card should not be revealed")
    }
    
    func testCardSingletonStartsFilled() {
        XCTAssertEqual(CardSingleton.shared.cards.isEmpty, false)
    }
    
}
