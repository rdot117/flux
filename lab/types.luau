export type Test = {
	name: string,
	handler: () -> (),
	results: {string},

	errors: number,
	successes: number,

	skipped: boolean,
	thread: thread,
}

return nil