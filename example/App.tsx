import { useEvent } from "expo";
import FoundationModels from "expo-apple-foundation-models";
import { useCallback, useState } from "react";
import {
    Button,
    SafeAreaView,
    ScrollView,
    Text,
    TouchableOpacity,
    View,
} from "react-native";

export default function App() {
    // const onChangePayload = useEvent(ExpoAppleFoundationModels, 'onChange');

    const [isFoundationModelsEnabled, setIsFoundationModelsEnabled] = useState<
        string | undefined
    >();

    const [supportedEvents, setSupportedEvents] = useState<string[]>([]);

    const onFoundationModelsEnabled = useCallback(async () => {
        const isEnabled = await FoundationModels.isFoundationModelsEnabled();
        setIsFoundationModelsEnabled(isEnabled);
        console.log(isEnabled);
    }, []);

    const onSupportedEvents = useCallback(() => {
        const events = FoundationModels.supportedEvents();
        setSupportedEvents(events);
        console.log(events);
    }, []);

    const onGenerateText = useCallback(async () => {
        const result = await FoundationModels.generateText({
            prompt: "Hello, how are you?",
        });
        console.log(result);
    }, []);

    const onGenerateStructuredOutput = useCallback(async () => {
        const result = await FoundationModels.generateStructuredOutput({
            prompt: "Hello, how are you?",
        });
        console.log(result);
    }, []);

    const onGenerateWithTools = useCallback(async () => {
        const result = await FoundationModels.generateWithTools({
            prompt: "Hello, how are you?",
        });
        console.log(result);
    }, []);

    const onResetSession = useCallback(async () => {
        const result = await FoundationModels.resetSession();
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
                        {isFoundationModelsEnabled}
                    </Text>
                </View>

                <Button title="Supported Events" onPress={onSupportedEvents} />
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
