export type StructureProperty = {
    type?: "string" | "integer" | "number" | "boolean" | "object";
    description?: string;
    enum?: string[];
    properties?: StructureSchema;
};

export type StructureSchema = {
    [key: string]: StructureProperty;
};

export interface ToolParameter {
    type: "string" | "integer" | "number" | "boolean" | "object";
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
};
