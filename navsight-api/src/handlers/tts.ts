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

	const buf = new Uint8Array(await ttsAudio.arrayBuffer());
	console.info(`Got TTS response of size ${buf.byteLength} bytes`);

	return buf;
};
export interface TTSRequest {
	text: string;
	language: string;
	provider: 'openai' | 'elevenlabs';
}
