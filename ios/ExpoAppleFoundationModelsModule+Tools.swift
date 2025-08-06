import ExpoModulesCore
import FoundationModels

extension ExpoAppleFoundationModelsModule {
  func registerTool(toolDefinition: NSDictionary) throws -> Bool {
    guard let name = toolDefinition["name"] as? String,
      let description = toolDefinition["description"] as? String,
      let parameters = toolDefinition["parameters"] as? [String: [String: Any]] else {
      throw "INVALID_TOOL_DEFINITION"
    }
    
    let bridgeTool = BridgeTool(
      name: name,
      description: description,
      parameters: parameters,
      module: self
    )
    
    registeredTools[name] = bridgeTool
    return true
  }

  func handleToolResult(result: NSDictionary) throws -> Any {
    guard let id = result["id"] as? String else {
      throw "INVALID_RESULT"
    }
    
    if let handler = toolHandlers[id] {
      handler(id, result as! [String: Any])
      toolHandlers.removeValue(forKey: id)
    }
    
    return true
  }

  func generateWithTools(options: NSDictionary) throws -> Any {
    guard let session = session else {
      throw "SESSION_NOT_CONFIGURED"
    }
    
    guard let prompt = options["prompt"] as? String else {
      throw "INVALID_INPUT"
    }
    
    let maxTokens = options["maxTokens"] as? Int ?? 1000 // default to 1000 tokens
    let temperature = options["temperature"] as? Double ?? 0.5 // default to 0.5
    let toolTimeout = options["toolTimeout"] as? Int ?? 30000 // default to 30 seconds
    self.toolTimeout = toolTimeout

    Task {
      do {
        var generationOptions = GenerationOptions(sampling: .greedy)
        
        generationOptions = GenerationOptions(
            sampling: generationOptions.sampling,
            temperature: temperature,
            maximumResponseTokens: maxTokens
        )
        
        // Generate response with tools enabled
        let result = try await session.respond(
          to: prompt,
          options: generationOptions
        )
        
        return result.content
        
      } catch let error {
        let errorMessage = handleGeneratedError(error as! LanguageModelSession.GenerationError)
        throw "GENERATION_FAILED"
      }
    }
  }

  func invokeTool(name: String, id: String, parameters: [String: Any]) async throws -> String {
    return try await withCheckedThrowingContinuation { continuation in
      let continuationKey = id
      
      let handler = { (resultId: String, result: [String: Any]) in
        if resultId == id {
          if let success = result["success"] as? Bool, success {
            continuation.resume(returning: result["result"] as? String ?? "No result")
          } else {
            let error = result["error"] as? String ?? "Unknown tool execution error"
            continuation.resume(throwing: NSError(
              domain: "ToolExecutionError",
              code: 1,
              userInfo: [NSLocalizedDescriptionKey: error]
            ))
          }
        }
      }
      
      toolHandlers[continuationKey] = handler
      
      DispatchQueue.main.async {
        self.sendEvent(
          withName: "ToolInvocation",
          body: [
            "name": name,
            "id": id,
            "parameters": parameters
          ]
        )
      }
      
      Task {
        try await Task.sleep(nanoseconds: UInt64(self.toolTimeout) * 1_000_000)
        if self.toolHandlers[continuationKey] != nil {
          self.toolHandlers.removeValue(forKey: continuationKey)
          continuation.resume(throwing: NSError(
            domain: "ToolExecutionError",
            code: 2,
            userInfo: [NSLocalizedDescriptionKey: "Tool execution timeout"]
          ))
        }
      }
    }
  }
}
