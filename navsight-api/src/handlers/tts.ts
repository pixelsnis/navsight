import OpenAI from 'openai';
import { Env } from '..';

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

	const audio = await openai.audio.speech.create({
		model: 'gpt-4o-mini-tts',
		response_format: 'mp3',
		voice: 'alloy',
		input: request.text,
		instructions: `Speak in a clean, refined Indian accent. Keeep a natural yet slightly upbeat tone. Speak in ${request.language}`,
	});

	return Buffer.from(await audio.arrayBuffer());
};
export interface TTSRequest {
	text: string;
	language: string;
}
