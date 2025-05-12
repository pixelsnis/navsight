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
};
export interface TTSRequest {
	text: string;
	language: string;
}
