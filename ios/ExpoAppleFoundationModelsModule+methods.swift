import ExpoModulesCore
import FoundationModels

@available(iOS 26, *)
extension ExpoAppleFoundationModelsModule {
  func isFoundationModelsEnabled() -> String {
    #if canImport(FoundationModels)
        // SystemLanguageModel is available in FoundationModels
        let model = SystemLanguageModel.default
          switch model.availability {
          case .available:
            return "available"
          case .unavailable(.appleIntelligenceNotEnabled):
            return "appleIntelligenceNotEnabled"
          case .unavailable(.modelNotReady):
            return "modelNotReady"
          default:
            return "unavailable"
          }
    #else
      return "unavailable"
    #endif
  }

  func configureSession(config: NSDictionary) {
    let instructions = Instructions {
      if let prompt = config["instructions"] as? String {
        prompt
      } else {
        "You are a helpful assistant that returns structured JSON data based on a given schema."
      }
    }

    let tools = Array(registeredTools.values)
    self.session = LanguageModelSession(tools: tools, instructions: instructions)
  }

  func generateStructuredOutput(options: NSDictionary) async throws -> Any {
       guard let session = session else {
        throw NSError(domain: "BridgeToolError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Session not configured"])
      }

      guard let schema = options["structure"] as? [String: Any] else {
        throw NSError(domain: "generateStructuredOutput", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid input"])
      }

      guard let prompt = options["prompt"] as? String else {
        throw NSError(domain: "generateStructuredOutput", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid input"])
      }
      
      let _dynamicSchema: GenerationSchema
      do {
        _dynamicSchema = try GenerationSchema(root: dynamicSchema(from: schema), dependencies: [])
      } catch {
        throw NSError(domain: "generateStructuredOutput", code: 1, userInfo: [NSLocalizedDescriptionKey: "Generation schema error"])
      }

      do {
        let result = try await session.respond(
          to: prompt,
          schema: _dynamicSchema,
          includeSchemaInPrompt: false,
          options: GenerationOptions(sampling: .greedy)
        )
        let flattened = try flattenGeneratedContent(result.content)
        return flattened
      } catch {
        throw NSError(domain: "generateStructuredOutput", code: 1, userInfo: [NSLocalizedDescriptionKey: "Generation failed"])
      }
  }

  func generateText(options: NSDictionary) async throws -> String {
     guard let session = session else {
        throw NSError(domain: "generateText", code: 1, userInfo: [NSLocalizedDescriptionKey: "Session not configured"])
      }

      guard let prompt = options["prompt"] as? String else {
        throw NSError(domain: "generateText", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid input"])
      }

      do {
        let result = try await session.respond(
          to: prompt,
          options: GenerationOptions(sampling: .greedy)
        )
        return result.content
      } catch {
        throw NSError(domain: "generateText", code: 1, userInfo: [NSLocalizedDescriptionKey: "Generation failed"])
      }
  }
}
