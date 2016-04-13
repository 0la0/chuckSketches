Impulse impulse => BiQuad biQuadFilter => dac;
0.99 => biQuadFilter.prad;
1 => biQuadFilter.eqzs;
0.2 => biQuadFilter.gain;

120::ms => dur baseDuration;
0 => int beatCnt;
0 => int totalTime;

0.1 => float repeatThreshold;

//TODO: Use bag of frequencies
[1000, 2000, 3000, 4000, 50000] @=> int beatFrequencyList[];

//--- LIST OF PROBABILITY TRESHOLDS, 32 STEP SEQUENCER ---//
[ 0.4, 0.03, 0.75, 0.05,
  0.3, 0.03, 0.75, 0.1,
  0.3, 0.03, 0.75, 0.05,
  0.4, 0.03, 0.75, 0.1,
  0.3, 0.03, 0.75, 0.05,
  0.3, 0.03, 0.75, 0.1,
  0.4, 0.03, 0.75, 0.05,
  0.3, 0.03, 0.75, 0.1 ] @=> float probs[];

probs.cap() => int numBeats;

function void repeatBeat ( int rate, int limit, int total ) {
  <<<rate, limit, total>>>;
  if (total >= limit) { return; }

  1.0 => impulse.next;
  rate + total => total;
  rate::ms => now;
  return repeatBeat(rate, limit, total);
}

function void easeRepeat (int rate, int limit, int total) {
  <<<rate, limit, total>>>;
  if (rate + total >= limit) {
    <<<"advance by", (limit - total)>>>;
    (limit - total)::ms => now;
    return;
  }

  1.0 => impulse.next;
  rate + total => total;
  rate::ms => now;
  rate + 10 => rate;

  return easeRepeat(rate, limit, total);
}

function void easeRepeat () {
  Math.random2f(1, 48) $ int => int rate;
  Math.random2f(1, 4) $ int => int beatDuration;
  120 + (beatDuration * 120) => int timeDuration;

  easeRepeat(rate, timeDuration, 0);
  (beatCnt + beatDuration) % numBeats => beatCnt;
}

while (true) {
  false => int isRepeat;

  if (totalTime % 120 == 0) {
    0 => totalTime;

    if (Std.rand2(0, 1) <= probs[beatCnt]) {
      if (beatCnt == 0) {
        1000 => biQuadFilter.pfreq;
        1.0 => impulse.next;
      }
      else if (beatCnt % 8 == 0) {
        1000 => biQuadFilter.pfreq;
        1.0 => impulse.next;

        if (Math.random2f(0, 1) <= repeatThreshold) {
          true => isRepeat;
          easeRepeat();
        }


      }
      else if (beatCnt % 4 == 0) {
        5000 => biQuadFilter.pfreq;
        1.0 => impulse.next;

        if (Math.random2f(0, 1) <= repeatThreshold) {
          true => isRepeat;
          easeRepeat();
        }

      }
      else {
        100 + 5000 * Math.random2f(0, 1) => float randFreq;
        1.0 => impulse.next;
        randFreq => biQuadFilter.pfreq;

        if (Math.random2f(0, 1) <= repeatThreshold) {
          true => isRepeat;
          easeRepeat();
        }

      }
    }

    (beatCnt + 1) % numBeats => beatCnt;
  }

  if (!isRepeat) {
    totalTime++;
    1::ms => now;
  }

}
