import ExpoModulesCore
import FoundationModels

@available(iOS 26, *)
public class ExpoAppleFoundationModelsModule: Module {
   // MARK: Declarations [END]
  public func definition() -> ModuleDefinition {
    Name("FoundationModels")

    Function("supportedEvents") { 
      return ["ToolInvocation"]
    }

    AsyncFunction("isFoundationModelsEnabled") {
      return isFoundationModelsEnabled()
    }

    AsyncFunction("configureSession") { (config: [String: Any]) in
      configureSession(config: config)
    }

    AsyncFunction("generateStructuredOutput") { (options: [String: Any]) async throws -> Any in
      return try await generateStructuredOutput(options: options)
    }

    AsyncFunction("generateText") { (options: [String: Any]) async throws -> String in
      return try await generateText(options: options)
    }

    AsyncFunction("resetSession") {
      return resetSession()
    }

    AsyncFunction("generateWithTools") { (options: [String: Any]) async throws -> String in
      return try await generateWithTools(options: options)
    }
  }
  // MARK: Declarations [END]

    internal var session: LanguageModelSession?
    internal var registeredTools: [String: BridgeTool] = [:]
    internal var toolHandlers: [String: (String, [String: Any]) -> Void] = [:]
    internal var toolTimeout: Int = 30000

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


@available(iOS 26, *)
class BridgeTool: Tool, @unchecked Sendable {

    typealias Arguments = GeneratedContent

    let name: String
    let description: String
    let schema: GenerationSchema
    private weak var module: ExpoAppleFoundationModelsModule?

    var parameters: GenerationSchema {
        return schema
    }
  
    init(name: String, description: String, parameters: [String: [String: Any]], module: ExpoAppleFoundationModelsModule) {
        self.name = name
        self.description = description
        self.module = module
        
        let rootSchema = module.dynamicSchema(from: parameters, name: name)
        self.schema = try! GenerationSchema(root: rootSchema, dependencies: [])
    }

    func call(arguments: GeneratedContent) async throws -> Prompt {
        guard let module = module else {
            throw NSError(domain: "BridgeToolError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Module reference lost"])
        }
    
        let invocationArgs = try module.flattenGeneratedContent(arguments) as? [String: Any] ?? [:]
        
        let id = UUID().uuidString
        let toolOutput = try await module.invokeTool(name: name, id: id, parameters: invocationArgs)
        return Prompt(toolOutput)
    }
}