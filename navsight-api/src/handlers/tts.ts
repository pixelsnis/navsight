import OpenAI from 'openai';
import { Env } from '..';

// Handles the TTS request by validating the request method, extracting the request body,
// generating the TTS audio, and streaming the audio back to the client.
export const handleTTSRequest = async (request: Request, env: Env): Promise<Response> => {
	try {
		// Validate the request method to ensure it's a POST request.
		if (request.method !== 'POST') {
			return new Response('Expected POST request', { status: 405 });
		}
		// Extract the TTS request body from the request.
		const body: TTSRequest = await request.json();

		// Create a TransformStream to handle the streaming of the TTS audio.
		const { readable, writable } = new TransformStream();
		const writer = writable.getWriter();

		// Generate the TTS audio based on the request body.
		const buffer = await getTTSAudio(body, env);

		// Write the generated TTS audio buffer to the writer.
		for (const buf of buffer) {
			writer.write(buf);
		}

		// Return the response with the TTS audio stream.
		return new Response(readable, { status: 200 });
	} catch (err) {
		console.error(err);
		return new Response('Internal server error', { status: 500 });
	}
};

// Generates the TTS audio based on the request parameters.
export const getTTSAudio = async (request: TTSRequest, env: Env) => {
	const openai = new OpenAI({ apiKey: env.OPENAI_KEY });

	// Create the TTS audio with specific settings for voice, tone, and delivery.
	const ttsAudio = await openai.audio.speech.create({
		model: 'gpt-4o-mini-tts',
		response_format: 'mp3',
		voice: 'sage',
		input: request.text,
		instructions: `
		Voice Affect: Soft voice, speaking at the rate of typical conversation. Professional.

		Tone: Neutral and informative, maintaining a balance between formality and approachability.

		Punctuation: Structured with commas and pauses for clarity, ensuring information is digestible and well-paced.

		Delivery: Steady and measured, with slight emphasis on key figures and deadlines to highlight critical points.
		`,
	});

	// Convert the TTS audio response to a Uint8Array buffer.
	const buf = new Uint8Array(await ttsAudio.arrayBuffer());
	console.info(`Got TTS response of size ${buf.byteLength} bytes`);

	return buf;
};
export interface TTSRequest {
	text: string;
	language: string;
	provider: 'openai' | 'elevenlabs';
}
