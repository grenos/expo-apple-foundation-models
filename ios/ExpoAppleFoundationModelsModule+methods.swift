import ExpoModulesCore
import FoundationModels

extension ExpoAppleFoundationModelsModule {
  func isFoundationModelsEnabled() -> String {
    #if canImport(FoundationModels)
      if #available(iOS 26, *) {
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
      } else {
        return "unavailable"
      }
    #else
      return "unavailable"
    #endif
  }

  func configureSession(config: NSDictionary) -> Bool {
    let model = SystemLanguageModel.default

    if model.availability != .available {
      print("Foundation Models are not available")
      return false
    }

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
  }

  func generateStructuredOutput(options: NSDictionary) throws -> Any {
       guard let session = session else {
        throw "SESSION_NOT_CONFIGURED"
      }

      guard let schema = options["structure"] as? [String: Any] else {
        throw "INVALID_INPUT"
      }

      guard let prompt = options["prompt"] as? String else {
        throw "INVALID_INPUT"
      }
      
      let _dynamicSchema: GenerationSchema
      do {
        _dynamicSchema = try GenerationSchema(root: dynamicSchema(from: schema), dependencies: [])
      } catch {
        throw "GENERATION_SCHEMA_ERROR"
      }

      Task {
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
          throw "GENERATION_FAILED"
        }
      }
  }

  func generateText(options: NSDictionary) throws -> Any {
     guard let session = session else {
        throw "SESSION_NOT_CONFIGURED"
      }

      guard let prompt = options["prompt"] as? String else {
        throw "INVALID_INPUT"
      }

      Task {
        do {
          let result = try await session.respond(
          to: prompt,
          options: GenerationOptions(sampling: .greedy)
          )
          return result.content
        } catch let error{
          throw "GENERATION_FAILED"
        }
      } 
  }
}
