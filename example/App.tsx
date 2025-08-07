import { useEvent } from "expo";
import FoundationModels, {
    isFoundationModelsEnabled,
    ToolDefinition,
    ToolSchema,
} from "expo-apple-foundation-models";
import { useCallback, useState } from "react";
import { Button, SafeAreaView, ScrollView, Text, View } from "react-native";

// Define your tools
const weatherSchema: ToolSchema = {
    name: "weather",
    description: "Get the current weather in a given location",
    parameters: {
        city: {
            type: "string",
            description: "The city to get the weather for",
            name: "city",
        },
    },
};

const weatherHandler = async (param: any) => {
    return `The weather in ${param.city.value} is sunny.`;
};

const weatherTool: ToolDefinition = {
    schema: weatherSchema,
    handler: weatherHandler,
};

export default function App() {
    // const onChangePayload = useEvent(ExpoAppleFoundationModels, 'onChange');

    const [_isFoundationModelsEnabled, setIsFoundationModelsEnabled] = useState<
        string | undefined
    >();

    const [supportedEvents, setSupportedEvents] = useState<string[]>([]);

    const onFoundationModelsEnabled = useCallback(async () => {
        const isEnabled = await isFoundationModelsEnabled();
        setIsFoundationModelsEnabled(isEnabled);
        console.log(isEnabled);
    }, []);

    const onGenerateText = useCallback(async () => {
        try {
            const session = new FoundationModels();
            const configured = await session.configure({
                instructions: "You are a helpful assistant.",
            });

            const response = await session.generateText({
                prompt: "Explain React Native in one sentence",
            });

            console.log(response);
            session.dispose();
        } catch (error) {
            console.error(error);
        }
    }, []);

    const onGenerateStructuredOutput = useCallback(async () => {
        try {
            const session = new FoundationModels();
            await session.configure({
                instructions: "You are a helpful assistant.",
            });

            const result = await session.generateStructuredOutput({
                prompt: "Extract name from: John Smith",
                structure: { name: { type: "string" } },
            });
            console.log(result);
            session.dispose();
        } catch (error) {
            console.error(error);
        }
    }, []);

    const onGenerateWithTools = useCallback(async () => {
        try {
            const session = new FoundationModels();
            await session.configure(
                {
                    instructions: "You are a helpful assistant.",
                },
                [weatherTool]
            );

            const response = await session.generateWithTools({
                prompt: "What is the weather in Monrovia, California?",
            });
            console.log(response);
            session.dispose();
        } catch (error) {
            console.error(error);
        }
    }, []);

    const onResetSession = useCallback(async () => {
        const session = new FoundationModels();
        const result = await session.reset();
        console.log(result);
    }, []);

    return (
        <SafeAreaView style={styles.container}>
            <ScrollView style={styles.container}>
                <Text style={styles.header}>Module API Example</Text>

                <View style={styles.group}>
                    <Text>Supported Events: {supportedEvents.join(", ")}</Text>
                    <Text>
                        Is Foundation Models Enabled:{" "}
                        {_isFoundationModelsEnabled}
                    </Text>
                </View>

                <Button
                    title="Is Foundation Models Enabled"
                    onPress={onFoundationModelsEnabled}
                />
                <Button title="Generate Text" onPress={onGenerateText} />
                <Button
                    title="Generate Structured Output"
                    onPress={onGenerateStructuredOutput}
                />
                <Button
                    title="Generate With Tools"
                    onPress={onGenerateWithTools}
                />
                <Button title="Reset Session" onPress={onResetSession} />
            </ScrollView>
        </SafeAreaView>
    );
}

function Group(props: { name: string; children: React.ReactNode }) {
    return (
        <View style={styles.group}>
            <Text style={styles.groupHeader}>{props.name}</Text>
            {props.children}
        </View>
    );
}

const styles = {
    header: {
        fontSize: 30,
        margin: 20,
    },
    groupHeader: {
        fontSize: 20,
        marginBottom: 20,
    },
    group: {
        margin: 20,
        backgroundColor: "#fff",
        borderRadius: 10,
        padding: 20,
    },
    container: {
        flex: 1,
        backgroundColor: "#eee",
    },
    view: {
        flex: 1,
        height: 200,
    },
};
