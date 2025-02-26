//
//  Home+UITest.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 26/02/2025.
//

import XCTest
@testable import CoinMB

final class HomeUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        // Configura o ambiente mockado através de argumentos de inicialização
        app.launchArguments = ["UI_TESTING"]
        app.launchEnvironment = ["MOCK_NETWORK": "true"]
    }

    func testSearchButton() {
        app.launch()
        let searchButton = app.buttons["Home.ContentHeader.searchButton"]
        searchButton.tap()
        // Adicione verificações para o comportamento esperado com dados mockados
    }

    func testFilterButton() {
        app.launch()
        let filterButton = app.buttons["Home.ContentHeader.filterButton"]
        filterButton.tap()
    }

    func testContentCell() {
        app.launch()
        let contentCell = app.otherElements["Home.ContentCell.USD"]
        XCTAssertTrue(contentCell.exists, "A célula USD deveria estar visível")
        contentCell.tap()
    }

    func testLineChartView() {
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
