Impulse impulse;
BiQuad biQuadFilter;
Echo echo;
JCRev reverb;

OscRecv oscReceiver;
OscEvent accelerometerOscEvent;
OscEvent reverbOscEvent;
OscEvent delayOscEvent;

float timeToAdvance;

function void initializeVariables () {
  0.99 => biQuadFilter.prad;
  1 => biQuadFilter.eqzs;
  0.2 => biQuadFilter.gain;
  500 => biQuadFilter.pfreq;
  0 => reverb.mix;
  100 => timeToAdvance;

  8081 => oscReceiver.port;
  oscReceiver.listen();
  oscReceiver.event("/accelerometer, ffff") @=> accelerometerOscEvent;
  oscReceiver.event("/reverb, f") @=> reverbOscEvent;
  oscReceiver.event("/delay, f") @=> delayOscEvent;
}

function void accelerometerListener () {
  while (true) {
    accelerometerOscEvent => now;
    accelerometerOscEvent.nextMsg();
    accelerometerOscEvent.getFloat() => float alpha;
    accelerometerOscEvent.getFloat() => float beta;
    accelerometerOscEvent.getFloat() => float gamma;
    accelerometerOscEvent.getFloat() => float blank;

    normalizeAccelerometerValue(alpha) * 500 + 5 => timeToAdvance;
    normalizeAccelerometerValue(beta) * 4000 => biQuadFilter.pfreq;
  }
}

function void reverbListener () {
  while (true) {
    reverbOscEvent => now;
    reverbOscEvent.nextMsg();
    reverbOscEvent.getFloat() => float reverbValue;
    Math.max(0, Math.min(reverbValue, 1)) => reverb.mix;
  }
}

function void delayListener () {
  while (true) {
    delayOscEvent => now;
    delayOscEvent.nextMsg();
    delayOscEvent.getFloat() => float delayValue;
  }
}

function void soundShred () {
  impulse => biQuadFilter => reverb => dac;
  while (true) {
    1.0 => impulse.next;
    timeToAdvance::ms => now;
  }
}

function float normalizeAccelerometerValue (float value) {
  Math.max(-9.8, Math.min(value, 9.8)) => value;
  (value / 9.8) => value;
  ((value + 1) / 2) => value;
  return value;
}

function void init () {
  initializeVariables();
  spork ~ accelerometerListener();
  spork ~ reverbListener();
  spork ~ delayListener();
  spork ~ soundShred();
}

init();
1::week => now;
