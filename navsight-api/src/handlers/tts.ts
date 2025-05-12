import OpenAI from 'openai';
import { Env } from '..';
import { ElevenLabsClient } from 'elevenlabs';

export const handleTTSRequest = async (request: Request, env: Env): Promise<Response> => {
	try {
		if (request.method !== 'POST') {
			return new Response('Expected POST request', { status: 405 });
		}
		const body: TTSRequest = await request.json();

		const { readable, writable } = new TransformStream();
		const writer = writable.getWriter();

		const buffer = await getTTSAudio(body, env);

		for (const buf of buffer) {
			writer.write(buf);
		}

		return new Response(readable, { status: 200 });
	} catch (err) {
		console.error(err);
		return new Response('Internal server error', { status: 500 });
	}
};

export const getTTSAudio = async (request: TTSRequest, env: Env) => {
	// For the sake of not going broke, there's an option to use the ElevenLabs API or the OpenAI API for TTS.
	// It's mostly just for developer flexibility, especially when testing.
	if (request.provider === 'elevenlabs') {
		const voiceID: string = '3gsg3cxXyFLcGIfNbM6C';

		const client = new ElevenLabsClient({ apiKey: env.ELEVENLABS_KEY });
		const audio = await client.textToSpeech.convert(voiceID, {
			text: request.text,
			model_id: 'elevenlabs_multilingual_v2',
			output_format: 'mp3_44100_128',
			language_code: request.language ?? 'en-US',
		});

		var chunks: Buffer[] = [];

		for await (const buf of audio) {
			chunks.push(buf);
		}

		const content = Buffer.concat(chunks);
		return content;
	}

	const openai = new OpenAI({ apiKey: env.OPENAI_KEY });

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

	return Buffer.from(await ttsAudio.arrayBuffer());
};
export interface TTSRequest {
	text: string;
	language: string;
	provider: 'openai' | 'elevenlabs';
}
