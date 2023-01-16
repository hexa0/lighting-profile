local types = {}

export type ProfileData = {
	Lighting: {[string]: any};
	PostEffects:  {[string]: {[string]: any}};

	Sky: {[string]: any}?;
	Atmosphere: {[string]: any}?;
	Clouds: {[string]: any}?;
}

return types