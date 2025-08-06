import ExpoModulesCore
import FoundationModels

public class ExpoAppleFoundationModelsModule: Module {
   // MARK: Declarations [END]
  public func definition() -> ModuleDefinition {
    Name("FoundationModels")

    Function("supportedEvents") { () -> [String] in
      return ["ToolInvocation"]
    }

    AsyncFunction("isFoundationModelsEnabled") { () -> String in
      return isFoundationModelsEnabled()
    }

    AsyncFunction("configureSession") { (config: NSDictionary) -> Bool in
      return configureSession(config: config)
    }

    AsyncFunction("generateStructuredOutput") { (options: NSDictionary) throws -> Any in
      return try generateStructuredOutput(options: options)
    }

    AsyncFunction("generateText") { (options: NSDictionary) throws -> Any in
      return try generateText(prompt: options["prompt"] as? String ?? "")
    }

    AsyncFunction("resetSession") { () -> Bool in
      return resetSession()
    }

    AsyncFunction("generateWithTools") { (options: NSDictionary) throws -> Any in
      return try generateWithTools(options: options)
    }
  }
  // MARK: Declarations [END]

    private var session: LanguageModelSession?
    private var registeredTools: [String: BridgeTool] = [:]
    private var toolHandlers: [String: (String, [String: Any]) -> Void] = [:]
    private var toolTimeout: Int = 30000

  // MARK: Generables [START]
    @Generable
      struct GenerableString: Codable {
      @Guide(description: "A string value")
      var value: String
    }

    @Generable
    struct GenerableInt: Codable {
      @Guide(description: "An integer value")
      var value: Int
    }

    @Generable
    struct GenerableNumber: Codable {
      @Guide(description: "A floating-point number")
      var value: Double
    }

    @Generable
    struct GenerableBool: Codable {
      @Guide(description: "A boolean value")
      var value: Bool
    }
  // MARK: Generables [END]

  // MARK: Internal Functions [START]
  func resetSession() -> Bool {
    session = nil
    registeredTools.removeAll()
    toolHandlers.removeAll()
    return true
  }
  // MARK: Internal Functions [END]
}
