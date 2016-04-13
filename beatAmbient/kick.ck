//Reference: http://music.columbia.edu/~daniglesia/plork2013/

120::ms => dur baseDuration;

function void samplingThread (int centerPitch) {

	SndBuf kick => dac;
	kick.read("data/kick.wav");
	0.5 => kick.gain;
	0 => int beatIndex;

	while (true) {
		if (beatIndex == 0 || beatIndex == 4) {
			0 => kick.pos;
		}
		
		if (++beatIndex == 8) { 0 => beatIndex; }
		baseDuration => now;
	}
}

spork~ samplingThread(36); //random range around 36, C two octaves below middle C
//spork~ samplingThread(60); //random range around 60, middle C

1::week=>now;//without this, we hit the end of the program and it exits
