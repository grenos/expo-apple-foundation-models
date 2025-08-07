# expo-apple-foundation-models

A powerful Expo module that provides access to Apple's Foundation Models (Apple Intelligence) for iOS applications. This library enables you to integrate advanced AI capabilities including text generation, structured output, and tool calling directly into your React Native/Expo apps.

## Features

- ✨ **Text Generation**: Generate natural language responses using Apple's LLM
- 🏗️ **Structured Output**: Generate JSON responses that conform to your defined schemas
- 🛠️ **Tool Calling**: Enable the AI to call custom functions and tools
- 📱 **iOS Native**: Built specifically for iOS with Apple Intelligence support
- 🎯 **TypeScript Support**: Fully typed API for better developer experience

## Requirements

- iOS 26 with Apple Intelligence enabled
- Expo SDK 53+
- Compatible Apple device (iPhone 15 Pro/Pro Max)

## Installation

### For Expo Managed Projects

```bash
npx expo install expo-apple-foundation-models
```

### For Bare React Native Projects

First, ensure you have [installed and configured the `expo` package](https://docs.expo.dev/bare/installing-expo-modules/).

```bash
npm install expo-apple-foundation-models
```

Then run:

```bash
npx pod-install
```

#### Alternative: Pure React Native Library

If you prefer to use a bare React Native library without Expo dependencies, you can use [react-native-apple-llm](https://github.com/deveix/react-native-apple-llm) instead. This library provides similar functionality but is designed specifically for bare React Native projects without requiring Expo modules.

## Quick Start

```typescript
import FoundationModels, {
    isFoundationModelsEnabled,
} from "expo-apple-foundation-models";

// Check if Apple Intelligence is available
const isEnabled = await isFoundationModelsEnabled();
console.log(isEnabled); // 'available', 'appleIntelligenceNotEnabled', 'modelNotReady', or 'unavailable'

// Create and configure a session
const session = new FoundationModels();
await session.configure({
    instructions: "You are a helpful assistant.",
});

// Generate text
const response = await session.generateText({
    prompt: "Explain React Native in one sentence",
});

console.log(response);

// Clean up
session.dispose();
```

## API Reference

### Core Functions

#### `isFoundationModelsEnabled()`

Check if Apple Intelligence is available on the device.

```typescript
const availability = await isFoundationModelsEnabled();
// Returns: 'available' | 'appleIntelligenceNotEnabled' | 'modelNotReady' | 'unavailable'
```

### FoundationModels Class

The main class for managing AI sessions.

#### `configure(options, tools?)`

Configure the session with instructions and optional tools.

```typescript
await session.configure(
    { instructions: "You are a helpful assistant." },
    [weatherTool] // optional tools array
);
```

#### `generateText(options)`

Generate natural language text.

```typescript
const response = await session.generateText({
    prompt: "Write a haiku about programming",
});
```

#### `generateStructuredOutput(options)`

Generate JSON output that conforms to a schema.

```typescript
const result = await session.generateStructuredOutput({
    prompt: "Extract name and age from: John Smith is 30 years old",
    structure: {
        name: { type: "string", description: "Person's name" },
        age: { type: "integer", description: "Person's age" },
    },
});
// Returns: { name: "John Smith", age: 30 }
```

#### `generateWithTools(options)`

Generate text with the ability to call custom tools/functions.

```typescript
const response = await session.generateWithTools({
    prompt: "What's the weather in San Francisco?",
    maxTokens: 500,
    temperature: 0.7,
    toolTimeout: 10000,
});
```

#### `reset()`

Reset the session, clearing all configuration and tools.

```typescript
await session.reset();
```

#### `dispose()`

Clean up the session and free resources.

```typescript
session.dispose();
```

## Examples

### Basic Text Generation

```typescript
import FoundationModels from "expo-apple-foundation-models";

const generateStory = async () => {
    const session = new FoundationModels();

    try {
        await session.configure({
            instructions: "You are a creative storyteller.",
        });

        const story = await session.generateText({
            prompt: "Write a short story about a robot learning to paint",
        });

        console.log(story);
    } catch (error) {
        console.error("Error generating story:", error);
    } finally {
        session.dispose();
    }
};
```

### Structured Data Extraction

```typescript
const extractContactInfo = async (text: string) => {
    const session = new FoundationModels();

    try {
        await session.configure({
            instructions: "Extract contact information from text.",
        });

        const contactInfo = await session.generateStructuredOutput({
            prompt: `Extract contact details from: ${text}`,
            structure: {
                name: {
                    type: "string",
                    description: "Full name of the person",
                },
                email: {
                    type: "string",
                    description: "Email address",
                },
                phone: {
                    type: "string",
                    description: "Phone number",
                },
                company: {
                    type: "string",
                    description: "Company name",
                },
            },
        });

        return contactInfo;
    } finally {
        session.dispose();
    }
};

// Usage
const contact = await extractContactInfo(
    "Hi, I'm Sarah Johnson from TechCorp. You can reach me at sarah@techcorp.com or 555-0123."
);
```

### Tool Calling with Custom Functions

```typescript
import { ToolDefinition, ToolSchema } from "expo-apple-foundation-models";

// Define a weather tool
const weatherSchema: ToolSchema = {
    name: "get_weather",
    description: "Get current weather information for a city",
    parameters: {
        city: {
            type: "string",
            description: "The city to get weather for",
            name: "city",
        },
        units: {
            type: "string",
            description: "Temperature units (celsius or fahrenheit)",
            name: "units",
            enum: ["celsius", "fahrenheit"],
        },
    },
};

const weatherHandler = async (params: any) => {
    const { city, units } = params;
    // In a real app, you'd call a weather API here
    return `The weather in ${city.value} is 72°${units?.value === "celsius" ? "C" : "F"} and sunny.`;
};

const weatherTool: ToolDefinition = {
    schema: weatherSchema,
    handler: weatherHandler,
};

// Use the tool
const getWeatherInfo = async () => {
    const session = new FoundationModels();

    try {
        await session.configure(
            { instructions: "You are a helpful weather assistant." },
            [weatherTool]
        );

        const response = await session.generateWithTools({
            prompt: "What's the weather like in Tokyo? Use Celsius.",
            maxTokens: 200,
            temperature: 0.3,
        });

        console.log(response);
    } finally {
        session.dispose();
    }
};
```

### Multiple Tools Example

```typescript
// Calculator tool
const calculatorTool: ToolDefinition = {
    schema: {
        name: "calculate",
        description: "Perform basic mathematical calculations",
        parameters: {
            expression: {
                type: "string",
                description: "Mathematical expression to evaluate",
                name: "expression",
            },
        },
    },
    handler: async (params) => {
        try {
            // Simple evaluation (in production, use a proper math parser)
            const result = eval(params.expression.value);
            return `The result is ${result}`;
        } catch (error) {
            return "Error: Invalid mathematical expression";
        }
    },
};

// Date/time tool
const dateTimeTool: ToolDefinition = {
    schema: {
        name: "get_datetime",
        description: "Get current date and time information",
        parameters: {
            format: {
                type: "string",
                description: "Format for the date/time",
                name: "format",
                enum: ["full", "date", "time"],
            },
        },
    },
    handler: async (params) => {
        const now = new Date();
        const format = params.format?.value || "full";

        switch (format) {
            case "date":
                return now.toDateString();
            case "time":
                return now.toTimeString();
            default:
                return now.toString();
        }
    },
};

// Use multiple tools
const assistantWithTools = async () => {
    const session = new FoundationModels();

    try {
        await session.configure(
            {
                instructions:
                    "You are a helpful assistant with access to calculator and date/time tools.",
            },
            [calculatorTool, dateTimeTool]
        );

        const response = await session.generateWithTools({
            prompt: "What's the current date and what's 15 * 24?",
            maxTokens: 300,
        });

        console.log(response);
    } finally {
        session.dispose();
    }
};
```

### Error Handling

```typescript
import { isFoundationModelsEnabled } from "expo-apple-foundation-models";

const robustAICall = async () => {
    // Check availability first
    const availability = await isFoundationModelsEnabled();

    if (availability !== "available") {
        switch (availability) {
            case "appleIntelligenceNotEnabled":
                throw new Error(
                    "Apple Intelligence is not enabled on this device"
                );
            case "modelNotReady":
                throw new Error(
                    "AI model is not ready. Please try again later."
                );
            case "unavailable":
                throw new Error(
                    "Apple Intelligence is not available on this device"
                );
        }
    }

    const session = new FoundationModels();

    try {
        const configured = await session.configure({
            instructions: "You are a helpful assistant.",
        });

        if (!configured) {
            throw new Error("Failed to configure AI session");
        }

        const response = await session.generateText({
            prompt: "Hello, how are you?",
        });

        return response;
    } catch (error) {
        console.error("AI generation failed:", error);
        throw error;
    } finally {
        session.dispose();
    }
};
```

## TypeScript Support

```typescript
// Availability status
type FoundationModelsAvailability =
    | "available"
    | "appleIntelligenceNotEnabled"
    | "modelNotReady"
    | "unavailable";

// Configuration options
interface LLMConfigOptions {
    instructions?: string;
}

// Text generation options
interface LLMGenerateTextOptions {
    prompt: string;
}

// Structured output options
interface LLMGenerateOptions {
    structure: StructureSchema;
    prompt: string;
}

// Tool calling options
interface LLMGenerateWithToolsOptions {
    prompt: string;
    maxTokens?: number;
    temperature?: number;
    toolTimeout?: number;
}

// Tool definition
interface ToolDefinition {
    handler: (parameters: any) => Promise<any>;
    schema: ToolSchema;
}
```

## Best Practices

### 1. Always Check Availability

```typescript
const availability = await isFoundationModelsEnabled();
if (availability !== "available") {
    // Handle unavailable state
    return;
}
```

### 2. Proper Session Management

```typescript
const session = new FoundationModels();
try {
    // Use session
} finally {
    session.dispose(); // Always clean up
}
```

### 3. Configure Before Use

```typescript
// Always configure before generating
await session.configure({ instructions: "..." });
```

### 4. Handle Errors Gracefully

```typescript
try {
    const result = await session.generateText({ prompt: "..." });
} catch (error) {
    console.error("Generation failed:", error);
    // Provide fallback behavior
}
```

### 5. Use Appropriate Parameters

```typescript
await session.generateWithTools({
    prompt: "...",
    maxTokens: 500, // Reasonable limit
    temperature: 0.7, // Balance creativity and consistency
    toolTimeout: 10000, // 10 second timeout
});
```

## Troubleshooting

### Common Issues

**"Apple Intelligence not enabled"**

- Ensure your device supports Apple Intelligence
- Check that Apple Intelligence is enabled in Settings
- Verify iOS version is 18.1 or later

**"Model not ready"**

- Apple Intelligence models may need time to download/initialize
- Try again after a few minutes
- Check device storage and internet connection

**Tool calling timeouts**

- Increase `toolTimeout` parameter
- Ensure tool handlers complete quickly
- Add proper error handling in tool handlers

**Session configuration fails**

- Check that instructions are provided
- Ensure tools are properly defined
- Verify device compatibility

## License

MIT
