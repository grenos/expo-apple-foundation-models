import ExpoModulesCore
import FoundationModels

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

    func call(arguments: GeneratedContent) async throws -> ToolOutput {
        guard let module = module else {
            throw NSError(domain: "BridgeToolError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Module reference lost"])
        }
    
        let invocationArgs = try module.flattenGeneratedContent(arguments) as? [String: Any] ?? [:]
        
        let id = UUID().uuidString
        return ToolOutput(try await module.invokeTool(name: name, id: id, parameters: invocationArgs))
    }
}