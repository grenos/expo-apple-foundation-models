export type StructureProperty = {
    type?: "string" | "integer" | "number" | "boolean" | "object" | "array";
    description?: string;
    enum?: string[];
    properties?: StructureSchema;
};

export type StructureSchema = {
    [key: string]: StructureProperty;
};

export interface ToolParameter {
    type: "string" | "integer" | "number" | "boolean" | "object" | "array";
    description: string;
    name: string;
    enum?: string[];
}
// this describes the tool
export interface ToolSchema {
    name: string;
    description: string;
    parameters: { [key: string]: ToolParameter };
}
// tool description + the actual function
export interface ToolDefinition {
    handler: (parameters: any) => Promise<any>; // parameter should always look like a json
    schema: ToolSchema;
}

export interface LLMConfigOptions {
    instructions?: string;
}

export interface LLMGenerateOptions {
    structure: StructureSchema;
    prompt: string;
}

export interface LLMGenerateTextOptions {
    prompt: string;
}

export interface LLMGenerateWithToolsOptions {
    prompt: string;
    maxTokens?: number;
    temperature?: number;
    toolTimeout?: number; // in milliseconds
}

export interface ToolCall {
    name: string;
    parameters: any;
    id: string;
}

export type FoundationModelsAvailability =
    | "available"
    | "appleIntelligenceNotEnabled"
    | "modelNotReady"
    | "unavailable";

export type ToolInvocationEvent = {
    name: string;
    id: string;
    parameters: any;
};

export type ExpoAppleFoundationModelsEvents = {
    onChangeToolInvocation: (params: ToolInvocationEvent) => void;
};

export type ExpoAppleFoundationModels = {
    supportedEvents: () => [string];
    isFoundationModelsEnabled: () => Promise<FoundationModelsAvailability>;
    configureSession: (config: LLMConfigOptions) => boolean;
    generateStructuredOutput: (options: LLMGenerateOptions) => Promise<any>;
    generateText: (options: LLMGenerateTextOptions) => Promise<string>;
    resetSession: () => Promise<boolean>;
    generateWithTools: (
        options: LLMGenerateWithToolsOptions
    ) => Promise<string>;
} & ExpoAppleFoundationModelsEvents;

/**
 * Type definition for the FoundationModel class
 * Provides session-based management for Apple's Foundation Models (Apple Intelligence)
 */
export interface IFoundationModel {
    /**
     * Configure the session with options and tools
     * @param options Configuration options for the LLM session
     * @param tools Optional array of tool definitions that can be called by the LLM
     * @returns Promise that resolves to true if configuration was successful
     */
    configure(
        options: LLMConfigOptions,
        tools?: ToolDefinition[]
    ): Promise<boolean>;

    /**
     * Generate text using the configured session
     * @param options Options containing the prompt for text generation
     * @returns Promise that resolves to the generated text or response
     */
    generateText(options: LLMGenerateTextOptions): Promise<any>;

    /**
     * Generate structured output using a JSON schema
     * @param options Options containing the structure schema and prompt
     * @returns Promise that resolves to the structured output matching the schema
     */
    generateStructuredOutput(options: LLMGenerateOptions): Promise<any>;

    /**
     * Generate text with tool calling capabilities
     * @param options Options for generation including prompt and tool parameters
     * @returns Promise that resolves to the generated text with potential tool interactions
     */
    generateWithTools(options: LLMGenerateWithToolsOptions): Promise<any>;

    /**
     * Reset the session, clearing all tools and configuration
     * @returns Promise that resolves to true if reset was successful
     */
    reset(): Promise<boolean>;

    /**
     * Dispose of the session and clean up all resources
     * Should be called when the instance is no longer needed
     */
    dispose(): void;
}
