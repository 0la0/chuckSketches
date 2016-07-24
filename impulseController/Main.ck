Impulse impulse;
BiQuad biQuadFilter;
Gain delayGate;
Gain delayGain;
Gain mainGain;
JCRev reverb;
Gain feedback;
DelayL delay;

OscRecv oscReceiver;
OscEvent reverbOscEvent;
OscEvent delayGainOscEvent;
OscEvent delayFeedbackOscEvent;
OscEvent frequencyOscEvent;
OscEvent timeToRepeatOscEvent;
OscEvent timeToRepeatDetailOscEvent;
OscEvent timeToRepeatJitterOscEvent;

float timeToAdvance;
float timeToAdvanceJitter;

function void initializeVariables () {
  0.99 => biQuadFilter.prad;
  1 => biQuadFilter.eqzs;
  0.2 => biQuadFilter.gain;
  500 => biQuadFilter.pfreq;
  0 => reverb.mix;

  500::ms => delay.max => delay.delay;
  0.8 => feedback.gain;
  0.99 => delay.gain;
  0.0 => delayGate.gain;

  100 => timeToAdvance;
  0 => timeToAdvanceJitter;

  8081 => oscReceiver.port;
  oscReceiver.listen();
  oscReceiver.event("/reverb, f") @=> reverbOscEvent;
  oscReceiver.event("/delay/gain, f") @=> delayGainOscEvent;
  oscReceiver.event("/delay/feedback, f") @=> delayFeedbackOscEvent;
  oscReceiver.event("/frequency, f") @=> frequencyOscEvent;
  oscReceiver.event("/timeToRepeat/rough, f") @=> timeToRepeatOscEvent;
  oscReceiver.event("/timeToRepeat/detail, f") @=> timeToRepeatDetailOscEvent;
  oscReceiver.event("/timeToRepeat/jitter, f") @=> timeToRepeatJitterOscEvent;
}

function void reverbListener () {
  while (true) {
    reverbOscEvent => now;
    reverbOscEvent.nextMsg();
    reverbOscEvent.getFloat() => float reverbValue;
    Math.max(0, Math.min(reverbValue, 1)) => reverb.mix;
  }
}

function void delayGainListener () {
  while (true) {
    delayGainOscEvent => now;
    delayGainOscEvent.nextMsg();
    delayGainOscEvent.getFloat() => float value;
    Math.max(0, Math.min(value, 1)) => delayGate.gain;
  }
}

function void delayFeedbackListener () {
  while (true) {
    delayFeedbackOscEvent => now;
    delayFeedbackOscEvent.nextMsg();
    delayFeedbackOscEvent.getFloat() => float value;
    Math.max(0, Math.min(value, 1)) => feedback.gain;
  }
}

function void frequencyListener () {
  while (true) {
    frequencyOscEvent => now;
    frequencyOscEvent.nextMsg();
    frequencyOscEvent.getFloat() => float value;
    Math.max(0, Math.min(value, 1)) => float normalValue;
    normalValue * 4000 => biQuadFilter.pfreq;
  }
}

function void timeToRepeatListener () {
  while (true) {
    timeToRepeatOscEvent => now;
    timeToRepeatOscEvent.nextMsg();
    timeToRepeatOscEvent.getFloat() => float value;
    Math.max(0, Math.min(value, 1)) => float normalValue;
    normalValue * 450 + 20 => timeToAdvance;
  }
}

function void timeToRepeatDetailListener () {
  while (true) {
    timeToRepeatDetailOscEvent => now;
    timeToRepeatDetailOscEvent.nextMsg();
    timeToRepeatDetailOscEvent.getFloat() => float value;
    Math.max(0, Math.min(value, 1)) => float normalValue;
    normalValue * 20 => timeToAdvance;
  }
}

function void timeToRepeatJitterListener () {
  while (true) {
    timeToRepeatJitterOscEvent => now;
    timeToRepeatJitterOscEvent.nextMsg();
    timeToRepeatJitterOscEvent.getFloat() => float value;
    Math.max(0, Math.min(value, 1)) => float normalValue;
    normalValue * 50 => timeToAdvanceJitter;
  }
}

function void soundShred () {

  impulse => biQuadFilter => reverb => mainGain => dac;
  reverb => delayGate => delayGain => mainGain;
  delayGain => feedback => delay => delayGain;

  while (true) {
    1.0 => impulse.next;
    timeToAdvance + (timeToAdvanceJitter * Math.random2f(0, 1)) => float millisecondsToAdvance;
    millisecondsToAdvance::ms => now;
  }
}

function float normalizeAccelerometerValue (float value) {
  Math.max(-9.3, Math.min(value, 9.3)) => value;
  (value / 9.3) => value;
  ((value + 1) / 2) => value;
  return value;
}

function void init () {
  initializeVariables();
  spork ~ reverbListener();
  spork ~ delayGainListener();
  spork ~ delayFeedbackListener();
  spork ~ frequencyListener();
  spork ~ timeToRepeatListener();
  spork ~ timeToRepeatDetailListener();
  spork ~ timeToRepeatJitterListener();
  spork ~ soundShred();
}

init();
1::week => now;
