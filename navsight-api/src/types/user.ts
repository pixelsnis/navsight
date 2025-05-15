interface UserAccount {
	id: string;
	name: string;
	email: string;
	role: 'ward' | 'guardian';
	language: string;
}

interface GuardianInvite {
	id: string;
	sender: string;
	accepted: boolean;
	created: Date;
}
