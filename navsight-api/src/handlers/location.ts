import { Env } from '..';
import Groq from 'groq-sdk';
import { getTTSAudio } from './tts';

// Handles the location request by fetching the user's location, finding nearby landmarks, and generating a text response.
export const handleLocationRequest = async (request: Request, env: Env): Promise<Response> => {
	try {
		// Validate the request method to ensure it's a POST request.
		if (request.method !== 'POST') {
			return new Response('Expected POST request', { status: 405 });
		}

		// Extract the location data from the request body.
		const location: {
			lat: number;
			lng: number;
			language: string;
		} = await request.json();

		console.info('📍 Got user location', {
			location: location,
		});

		// Using the Maps API and the user's most recent coordinates, find out:
		// 1. The street and general area they're in
		// 2. Two nearby landmarks

		// --- Reverse Geocoding ---
		// Fetch the reverse geocoding data to determine the user's address.
		const geocodeRes = await fetch(
			`https://geocode.googleapis.com/v4beta/geocode/location?location.latitude=${location.lat}&location.longitude=${location.lng}&key=${env.MAPS_KEY}`
		);
		const geocodeData: any = await geocodeRes.json();

		console.info(`Received reverse geocode response`, {
			'geocode-response': geocodeData,
		});

		// Extract the user's address from the geocoding data.
		const userAddress = geocodeData.results[0]?.formattedAddress ?? 'an unknown location';
		console.info(`🗺️ User address: ${userAddress}`);

		// --- Places Nearby ---
		// Fetch the places nearby the user's location.
		const placesRes = await fetch(`https://places.googleapis.com/v1/places:searchNearby`, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
				'X-Goog-Api-Key': env.MAPS_KEY,
				'X-Goog-FieldMask': 'places.displayName',
			},
			body: JSON.stringify({
				maxResultCount: 5,
				locationRestriction: {
					circle: {
						center: {
							latitude: location.lat,
							longitude: location.lng,
						},
						radius: 50.0,
					},
				},
				rankPreference: 'POPULARITY',
			}),
		});

		const placesData: any = await placesRes.json();
		console.info(`Got response from nearby search`, {
			'nearby-search-response': placesData,
		});

		// Extract the names of nearby landmarks.
		const landmarks: any[] = placesData.places.map((place: any) => place.displayName.text);

		// Initialize the Groq client for generating a text response.
		const groq = new Groq({ apiKey: env.GROQ_API_KEY });

		// Generate a text response summarizing the user's location and nearby landmarks.
		const completion = await groq.chat.completions.create({
			model: 'meta-llama/llama-4-scout-17b-16e-instruct',
			messages: [
				{
					role: 'system',
					content: `
                    You are a helpful assistant for the blind that describes the location they are in. 
                    You will be provided their relative address and the names of important landmarks nearby. 
                    Summarize the location and landmark data given to you in one brief sentence to describe to the user where they are. 
					Reference the names of places rather than their general type (for example, say "Apple Park" instead of "a building")
					Refer only to at most 2 major landmarks from the data provided. Do not mention the city, it is implied.
                    Be extremely concise in your speech. Do not waste words. Speak in ${location.language} (ISO language code). Use simple, commonly-spoken words. 
                    `,
				},
				{
					role: 'user',
					content: `
                    Current address: ${userAddress} 

                    Nearby landmarks: ${landmarks.join(', ')}
                    `,
				},
			],
		});

		console.debug('💬 Groq completion:', completion);

		// Extract the generated text response.
		const textResponse = completion.choices[0].message.content;

		if (!textResponse) throw 'Groq response was empty';

		console.debug('Text response:', textResponse);

		// Generate the TTS audio for the text response.
		const ttsAudio = await getTTSAudio(
			{
				text: textResponse ?? 'Sorry, something went wrong. Please try again.',
				language: location.language,
				provider: 'openai',
			},
			env
		);

		// Set the transcription header for the response.
		const headers = new Headers();
		headers.set('X-Transcription', textResponse);

		return new Response(ttsAudio, { headers: headers, status: 200 });
	} catch (err) {
		console.error('Error handling location request:', err);
		return new Response('Internal server error', { status: 500 });
	}
};
