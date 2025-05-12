import { Loader } from '@googlemaps/js-api-loader';
import { Env, supabase, userID } from '..';
import { Location } from '../types/location';
import Groq from 'groq-sdk';
import { getTTSAudio } from './tts';

export const handleLocationRequest = async (request: Request, env: Env): Promise<Response> => {
	try {
		if (request.method !== 'GET') {
			return new Response('Expected GET request', { status: 405 });
		}

		const location: Location | undefined = (await supabase!.from('location').select().eq('user_id', userID!)).data?.map(
			(e) => e as Location
		)[0];

		if (!location) {
			console.debug('No location found for user ID:', userID);
			return new Response('No location found', { status: 404 });
		}

		// Using the Maps API and the user's most recent coordinates, find out:
		// 1. The street and general area they're in
		// 2. Two nearby landmarks

		const loader = new Loader({
			apiKey: env.MAPS_KEY,
			version: 'weekly',
		});

		const { Place } = await loader.importLibrary('places');
		const { Geocoder } = await loader.importLibrary('geocoding');

		const center = new google.maps.LatLng(location.latitude, location.longitude);

		console.debug('Center coordinates:', center);

		const { places } = await Place.searchNearby({
			fields: ['displayName'],
			locationRestriction: {
				center: center,
				radius: 50,
			},
			maxResultCount: 2,
			rankPreference: google.maps.places.SearchNearbyRankPreference.POPULARITY,
		});

		console.debug('Nearby places:', places);

		const landmarks = places.map((e) => `${e.displayName}`);

		console.debug('Landmarks:', landmarks);

		const geocoder = new Geocoder();
		const geocodedLocation = await geocoder.geocode({
			location: {
				lat: location.latitude,
				lng: location.longitude,
			},
		});

		console.debug('Geocoded location:', geocodedLocation);

		const userAddress = geocodedLocation.results[0].formatted_address;

		console.debug('User address:', userAddress);

		const userLanguagePreference: string =
			((await supabase!.from('users').select('language').eq('id', userID!)).data ?? [])[0].language ?? 'English';

		console.debug('User language preference:', userLanguagePreference);

		const groq = new Groq({ apiKey: env.GROQ_API_KEY });

		const completion = await groq.chat.completions.create({
			model: 'meta-llama/llama-4-scout-17b-16e-instruct',
			messages: [
				{
					role: 'system',
					content: `
                    You are a helpful assistant for the blind that describes the location they are in. 
                    You will be provided their relative address and the names of upto two important landmarks nearby. 
                    Summarize the location and landmark data given to you in one brief sentence to describe to the user where they are.
                    Be extremely concise in your speech. Do not waste words. Speak in ${userLanguagePreference} using English characters. Do not use complex language. 
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

		console.debug('Groq completion:', completion);

		const textResponse = completion.choices[0].message.content;

		if (!textResponse) throw 'Groq response was empty';

		console.debug('Text response:', textResponse);

		const ttsAudio = await getTTSAudio(
			{
				text: textResponse ?? 'Sorry, something went wrong. Please try again.',
				language: userLanguagePreference,
			},
			env
		);

		console.debug('TTS audio:', ttsAudio);

		const { readable, writable } = new TransformStream();
		const writer = writable.getWriter();

		const headers = new Headers();
		headers.set('X-Transcription', textResponse);

		for (const buf of ttsAudio) {
			writer.write(buf);
		}

		return new Response(readable, { headers: headers, status: 200 });
	} catch (err) {
		console.error('Error handling location request:', err);
		return new Response('Internal server error', { status: 500 });
	}
};
