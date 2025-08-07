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

  func configureSession(config: [String: Any]) async throws -> Bool {
    do {
    let instructions = Instructions {
      if let prompt = config["instructions"] as? String {
        prompt
      } else {
        "You are a helpful assistant that returns structured JSON data based on a given schema."
      }
    }

      let tools = Array(registeredTools.values)
      self.session = LanguageModelSession(tools: tools, instructions: instructions)
      return true
    } catch {
      return false
    }
  }

  func generateStructuredOutput(options: [String: Any]) async throws -> Any {
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
      } catch let error {
          let errorMessage = handleGeneratedError(error as! LanguageModelSession.GenerationError)
          throw NSError(domain: "generateStructuredOutput", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
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
      } catch let error{
          let errorMessage = handleGeneratedError(error as! LanguageModelSession.GenerationError)
        throw NSError(domain: "generateStructuredOutput", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
      }
  }

  func generateText(options: [String: Any]) async throws -> String {
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
      } catch let error {
        let errorMessage = handleGeneratedError(error as! LanguageModelSession.GenerationError)
        throw NSError(domain: "generateText", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
      }
  }
}
