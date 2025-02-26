//
//  Home+UITest.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 26/02/2025.
//

import XCTest
@testable import CoinMB

final class HomeUITests: XCTestCase {

    func testHomeView() {
        let app = XCUIApplication()
        app.launch()

        let homeView = app.otherElements["homeView"]
    }

    func testSearchButton() {
        let app = XCUIApplication()
        app.launch()

        let searchButton = app.buttons["Home.ContentHeader.searchButton"]
        searchButton.tap()
    }

    func testFilterButton() {
        let app = XCUIApplication()
        app.launch()

        let filterButton = app.buttons["Home.ContentHeader.filterButton"]
        filterButton.tap()
    }

    func testContentCell() {
        let app = XCUIApplication()
        app.launch()

        let contentCell = app.cells["Home.ContentCell"]
        contentCell.tap()
    }

    func testLineChartView() {
        let app = XCUIApplication()
        app.launch()

        let lineChartView = app.otherElements["Home.LineChartView"]
        
        // Realiza o gesto de dragging da direita para a esquerda
        let startCoordinate = lineChartView.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.5))
        let endCoordinate = lineChartView.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.5))
        startCoordinate.press(forDuration: 0.1, thenDragTo: endCoordinate)
        
        // Realiza o gesto de dragging da esquerda para a direita
        startCoordinate.press(forDuration: 0.1, thenDragTo: endCoordinate)
    }
}
