import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { handleLocationRequest } from './handlers/location';
import { handleTTSRequest } from './handlers/tts';
import { jwtVerify } from 'jose';

export interface Env {
	GROQ_API_KEY: string;
	SUPABASE_URL: string;
	SUPABASE_KEY: string;
	SUPABASE_JWT_SECRET: string;
	OPENAI_KEY: string;
	ELEVENLABS_KEY: string;
	MAPS_KEY: string;
}

export var supabase: SupabaseClient | undefined = undefined;
export var userID: string | undefined | null = undefined;

export default {
	async fetch(request, env, ctx): Promise<Response> {
		userID = await getUserIdFromToken(request, env);

		if (!userID) {
			return new Response('Unauthorized', { status: 401 });
		}

		const path = new URL(request.url).pathname.substring(1).split('/');

		const masterPath = path[0];

		supabase = createClient(env.SUPABASE_URL, env.SUPABASE_KEY);

		switch (masterPath) {
			case 'location':
				return await handleLocationRequest(request, env);
			case 'tts':
				return await handleTTSRequest(request, env);
			default:
				return new Response('Not found', { status: 404 });
		}
	},
} satisfies ExportedHandler<Env>;

async function getUserIdFromToken(request: Request, env: Env) {
	const authHeader = request.headers.get('Authorization');
	if (!authHeader || !authHeader.startsWith('Bearer ')) {
		return null;
	}

	const token = authHeader.split(' ')[1];
	const secret = new TextEncoder().encode(env.SUPABASE_JWT_SECRET);

	try {
		const { payload } = await jwtVerify(token, secret);
		return payload.sub; // this is the user ID
	} catch (e) {
		console.error('JWT verification failed:', e);
		return null;
	}
}
