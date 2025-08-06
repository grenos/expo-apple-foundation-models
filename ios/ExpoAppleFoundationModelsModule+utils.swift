import ExpoModulesCore
import FoundationModels

@available(iOS 26, *)
extension ExpoAppleFoundationModelsModule {
      func dynamicSchema(from json: [String: Any], name: String = "Root") -> DynamicGenerationSchema {
      var properties: [DynamicGenerationSchema.Property] = []

      for (key, raw) in json {
        guard let field = raw as? [String: Any] else { continue }
        let type = field["type"] as? String
        let description = field["description"] as? String
        let enumValues = field["enum"] as? [String]

        var childProperty: DynamicGenerationSchema.Property

        if let enumValues = enumValues {
          let childSchema = DynamicGenerationSchema(
            name: key,
            description: description,
            anyOf: enumValues
          )
          childProperty = DynamicGenerationSchema.Property(
            name: key, description: description, schema: childSchema)
        } else if type == "object", let nested = field["properties"] as? [String: Any] {
          let nestedSchema = dynamicSchema(from: nested, name: key)
          childProperty = DynamicGenerationSchema.Property(name: key, description: description, schema: nestedSchema)
        }
        // TODO: handle array?
        else {
          childProperty = schemaForType(name: key, type: type ?? "string", description: description)
        }

        properties.append(childProperty)
      }

      return DynamicGenerationSchema(name: name, properties: properties)
  } 

  private func schemaForType(name: String, type: String, description: String? = nil) -> DynamicGenerationSchema.Property {
    return schemaForPrimitiveType(name: name, type: type, description: description)
  }

  private func schemaForPrimitiveType(name: String, type: String, description: String? = nil) -> DynamicGenerationSchema.Property {
      let schema: DynamicGenerationSchema

      switch type {
      case "string":
        schema = DynamicGenerationSchema(
          type: GenerableString.self,
        )
      case "integer":
        schema = DynamicGenerationSchema(
          type: GenerableInt.self,
        )
      case "number":
        schema = DynamicGenerationSchema(
          type: GenerableNumber.self,
        )
      case "boolean":
        schema = DynamicGenerationSchema(
          type: GenerableBool.self,
        )
      default:
        schema = DynamicGenerationSchema(
          type: GenerableString.self,
        )
      }

    return DynamicGenerationSchema.Property(
      name: name,
      description: description,
      schema: schema
    )
  }

  func flattenGeneratedContent(_ content: GeneratedContent) throws -> Any {
      // Try extracting known primitive types
      if let stringVal = try? content.value(String.self) {
        return stringVal
      }
      if let intVal = try? content.value(Int.self) {
        return intVal
      }
      if let doubleVal = try? content.value(Double.self) {
        return doubleVal
      }
      if let boolVal = try? content.value(Bool.self) {
        return boolVal
      }

      // If it's an object with named properties
      if let props = try? content.properties() {
        var result: [String: Any] = [:]
        for (key, val) in props {
          result[key] = try flattenGeneratedContent(val)
        }
        return result
      }

      // If it's an array
      if let elements = try? content.elements() {
        return try elements.map { try flattenGeneratedContent($0) }
      }

      // Fallback
      return "\(content)"
  }

  func handleGeneratedError(_ error: LanguageModelSession.GenerationError) -> String {
    switch error {
    case .exceededContextWindowSize(let context):
        return presentGeneratedError(error, context: context)
    case .assetsUnavailable(let context):
        return presentGeneratedError(error, context: context)
    case .guardrailViolation(let context):
        return presentGeneratedError(error, context: context)
    case .unsupportedGuide(let context):
        return presentGeneratedError(error, context: context)
    case .unsupportedLanguageOrLocale(let context):
        return presentGeneratedError(error, context: context)
    case .decodingFailure(let context):
        return presentGeneratedError(error, context: context)
    case .rateLimited(let context):
        return presentGeneratedError(error, context: context)
    default:
        return "Failed to respond: \(error.localizedDescription)"
    }
  }

  func presentGeneratedError(_ error: LanguageModelSession.GenerationError, context: LanguageModelSession.GenerationError.Context) -> String {
    return """
        Failed to respond: \(error.localizedDescription).
        Failure reason: \(String(describing: error.failureReason)).
        Recovery suggestion: \(String(describing: error.recoverySuggestion)).
        Context: \(context)
        """
  }
}
