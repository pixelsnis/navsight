import { Env, supabase, userID } from '../';

export const handleInvitesEndpoint = async (request: Request, env: Env): Promise<Response> => {
	try {
		if (request.method !== 'POST') {
			return new Response('Expected POST request', { status: 405 });
		}

		const body: InviteAcceptRequest = await request.json();

		if (body.user_id !== userID) {
			return new Response('Conflicting user IDs received', { status: 403 });
		}

		const invite: GuardianInvite | undefined = (await supabase!.from('invites').select().eq('id', body.invite_id)).data?.map(
			(e) => e as GuardianInvite
		)[0];

		if (invite?.accepted === true) {
			return new Response('Invite already accepted', { status: 409 });
		}

		if (!invite) {
			return new Response('Invite not found', { status: 404 });
		}

		const updatePromises = [
			await supabase!.from('users').update({ guardian: body.user_id }).eq('id', invite.sender),
			await supabase!.from('invites').update({ accepted: true }).eq('id', invite.id),
		];

		await Promise.all(updatePromises);

		return new Response('OK', { status: 200 });
	} catch (err) {
		console.error(err);
		return new Response('Internal server error', { status: 500 });
	}
};

interface InviteAcceptRequest {
	invite_id: string;
	user_id: string;
}
