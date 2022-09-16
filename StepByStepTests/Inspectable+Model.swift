import ViewInspector
@testable import StepByStep

extension Inspection: InspectionEmissary {}

extension RecipeLineView: Inspectable {}
extension RecipeListView: Inspectable {}
extension TestingViewInspectorView: Inspectable {}

extension StepListView: Inspectable {}
extension StepLineView: Inspectable {}
extension StepEditorView: Inspectable {}
