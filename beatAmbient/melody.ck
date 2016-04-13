SinOsc osc;
ADSR adsr;
Echo delay;
JCRev reverb;

reverb => dac;
delay => reverb;
osc => adsr;
adsr => delay;
adsr => reverb;

//--- SET ADSR ENVELOPE ---//
1::ms => dur attack;
10::ms => dur decay;
500::ms => dur release;
attack + decay => dur noteOnset;
adsr.set(attack, decay, .5, release);

//--- SET OSC ---//
.5 => osc.gain;

//--- SET REVERB ---//
0.15 => reverb.mix;

//--- SET DELAY ---//
240::ms => delay.delay;
0.75 => delay.mix;

[60, 62, 64, 69, 69, 69, 69, 70, 72] @=> int notes[];
[30, 60, 120] @=> int durations[];
120::ms => dur baseDuration;

function int getRandElement (int arr[]) {
 return arr[ Std.rand2(0, arr.cap()-1) ];
}


while (true) {
  getRandElement(durations) => int duration;

  if (Std.rand2(0, 1) <= 0.25) {
    baseDuration => now;
  }
  else {
    getRandElement(notes) => int midiNote;
    Math.random2f(0, 1) => float randThreshold;
    if (randThreshold <= 0.5) {
      midiNote + 12 => midiNote;
    }
    Std.mtof(midiNote) => osc.freq;

    //--- PLAY OSC ---//
    adsr.keyOn();
    noteOnset => now;
    adsr.keyOff();

    //--- ADVANCE TIME ---//
    baseDuration - noteOnset => dur restTime;
    restTime => now;
  }

}
