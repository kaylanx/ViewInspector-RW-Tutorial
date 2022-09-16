import SwiftUI
import XCTest
@testable import ViewInspector
@testable import StepByStep

final class StepByStepTests: XCTestCase {
  func testViewInspectorBaseline() throws {
    let expected = "it lives!"
    let sut = Text(expected)
    let value = try sut.inspect().text().string()
    XCTAssertEqual(value, expected)
  }

  func testRecipeDefaultText() throws {
    let controller = RecipeController.previewController()
    let recipe = controller.createRecipe()

    let view = RecipeLineView(recipe: recipe)

    let inspectedName = try view
      .inspect()
      .find(text: AppStrings.defaultTitle)
      .string()
    XCTAssertEqual(AppStrings.defaultTitle, inspectedName)
    let inspectedDescription = try view
      .inspect()
      .find(text: AppStrings.defaultDescription)
      .string()
    XCTAssertEqual(AppStrings.defaultDescription, inspectedDescription)
  }

  func testRecipeText() throws {

    let expectedName = "Chicken Tikka Masala"
    let expectedLongDescription = "Dish consisting of marinated boneless chicken pieces that are traditionally cooked in a tandoor and then served in a subtly spiced tomato-cream sauce."

    let controller = RecipeController.previewController()
    let recipe = controller.createRecipe()
    recipe.name = expectedName
    recipe.longDescription = expectedLongDescription

    let view = RecipeLineView(recipe: recipe)

    let inspectedName = try view
      .inspect()
      .find(text:expectedName)
      .string()
    XCTAssertEqual(expectedName, inspectedName)
    let inspectedDescription = try view
      .inspect()
      .find(text: expectedLongDescription)
      .string()
    XCTAssertEqual(expectedLongDescription, inspectedDescription)
  }

  func testRecipeNameStyle() throws {
    let controller = RecipeController.previewController()
    let recipe = controller.createRecipe()
    let view = RecipeLineView(recipe: recipe)
    let inspectedName = try view.inspect().find(text: AppStrings.defaultTitle)

    let fontStyle = try inspectedName.attributes().font().style()
    XCTAssertEqual(fontStyle, .title2)

    let fontWeight = try inspectedName.attributes().fontWeight()
    XCTAssertEqual(fontWeight, .medium)
  }

  func testAddRecipeAddsRecipe() throws {

    let controller = RecipeController.previewController()
    var sut = RecipeListView()
    sut.inject(environmentObject: controller)

    let view = ViewInspectorWrapperView { sut }

    let expectation = view.inspection.inspect { view in
      XCTAssertEqual(controller.recipes.count, 0)
      try view.find(button: "Add Recipe").tap()
      XCTAssertEqual(controller.recipes.count, 1)
    }

    ViewHosting.host(view: view.environmentObject(controller))
    wait(for: [expectation], timeout: 1.0)
  }

  func testAddRecipeButtonHasCorrectStyle() throws {
    let controller = RecipeController.previewController()
    var sut = RecipeListView()
    sut.inject(environmentObject: controller)
    let view =  ViewInspectorWrapperView {
      sut
    }
    let expectation = view.inspection.inspect { view in
      let button = try view.find(button: "Add Recipe")
      XCTAssertTrue(try button.buttonStyle() is AdditiveButtonStyle)
    }
    ViewHosting.host(view: view.environmentObject(controller))
    wait(for: [expectation], timeout: 1.0)
  }

  func testAdditiveButtonStylePressedState() throws {
    let style = AdditiveButtonStyle()
    XCTAssertEqual(try style.inspect(isPressed: true).scaleEffect().width, 1.1)
    XCTAssertEqual(try style.inspect(isPressed: false).scaleEffect().width, 1.0)
  }

  func makeStepController(_ count: Int) -> StepController {
    let recipeController = RecipeController.previewController()
    let recipe = recipeController.createRecipe()
    for idx in 1...count {
      let step = recipeController.createStep(for: recipe)
      step.name = stubStepName(idx)
      step.orderingIndex = Int16(idx)
    }

    let stepController = StepController(
      recipe: recipe,
      dataStack: recipeController.dataStack
    )
    return stepController
  }

  func testStepListCellCountSmall() throws {
    let expectedCount = 20
    let stepController = makeStepController(expectedCount)
    let view = ViewInspectorWrapperView {
      StepListView(stepController: stepController)
    }

    let expectation = view.inspection.inspect { view in
      let cells = view.findAll(StepLineView.self)
      XCTAssertEqual(cells.count, expectedCount)
    }

    ViewHosting.host(view: view)
    wait(for: [expectation], timeout: 1.0)
  }

  func testStepListCellContent() throws {
    let expectedCount = 10
    let stepController = makeStepController(expectedCount)
    let view = ViewInspectorWrapperView {
      StepListView(stepController: stepController)
    }

    let expectation = view.inspection.inspect { view in
      for idx in 1...expectedCount {
        _ = try view.find(StepLineView.self, containing: self.stubStepName(idx))
      }
    }
    ViewHosting.host(view: view)
    wait(for: [expectation], timeout: 1.0)
  }

  func testStepCellNavigationLink() throws {
    let expectedCount = 1
    let stepController = makeStepController(expectedCount)
    let view = ViewInspectorWrapperView {
      StepListView(stepController: stepController)
    }

    let expectation = view.inspection.inspect { view in
      let navLink = try view.find(ViewType.NavigationLink.self)
      _ = try navLink.view(StepEditorView.self)
    }
    ViewHosting.host(view: view)
    wait(for: [expectation], timeout: 1.0)
  }

  private func stubStepName(_ index: Int) -> String {
    "Step -\(index)"
  }
}
