// =====================================================================
// Epsilon - Audio Generation & Purification System
// =====================================================================

// 1. Server Configuration
s.options.outDevice = "AirPods Pro";
s.options.sampleRate = 48000;
s.options.numInputBusChannels = 0;
s.options.numOutputBusChannels = 2;

// 2. Global Internal States (Autonomous System Parameters)
~tension           = 0.0;
~vitality          = 1.0;
~fatigue           = 0.0;
~internal_pressure = 0.0;
~isDreaming        = 0;

// 3. OSC Network Receiver
OSCdef(\epsilonState, { |msg|
    ~tension           = msg[1];
    ~vitality          = msg[2];
    ~fatigue           = msg[3];
    ~internal_pressure = msg[4];
    ~isDreaming        = msg[5];
}, '/epsilon/state');

// =====================================================================
// 4. Main Generative Routine
// =====================================================================
s.waitForBoot({
    Routine({
        var totalDuration = 300;  // 全体の長さ（5分）
        var purifyTime    = 240;  // 不純物が消え去るまでの時間（4分）
        var recordPath    = Platform.userHomeDir +/+ "Desktop/epsilon_pure_sine_final.wav";

        s.prepareForRecord(recordPath);
        2.wait;
        s.record;
        "--- 録音開始：最後は正弦波だけが残ります ---".postln;

        // --- DSP Graph Engine ---
        x = {
            var sig, voices, chord, mainEnv, purifyEnv, rev;
            var t_tension, t_vitality, t_fatigue, t_pressure;

            // 内部状態パラメーターの平滑化 (Smooth Lag)
            t_tension  = ~tension.lag(5.0);
            t_vitality = ~vitality.lag(5.0);
            t_fatigue  = ~fatigue.lag(5.0);
            t_pressure = ~internal_pressure.lag(5.0);

            // 【純化エンベロープ】 0.0 (カオス) -> 1.0 (完全な純粋)
            purifyEnv = Line.kr(0, 1, purifyTime).clip(0, 1);

            // 【メインボリュームエンベロープ】 最後に余韻を残すため緩やかにリリース
            mainEnv = EnvGen.kr(
                Env([0, 0.4 * t_vitality, 0.4 * t_vitality, 0], [30, 260, 10], \sin)
            );

            // 倍音構造の定義 (MIDI Notes)
            chord = [36, 48, 55, 62, 64, 67, 71, 74, 78, 81];

            // 音源生成：純粋なサイン波と消えゆくモアレ成分の分離
            voices = chord.collect({ |midi, i|
                var freq = midi.midicps;
                var pureSine, moireElements, staticAmp, movingAmp;

                // A. 純粋な正弦波 (Essential Layer)
                pureSine = SinOsc.ar(freq, Rand(0, 2pi));

                // B. 不純物・モアレ・倍音 (Artifacts Layer - 途中で完全に消滅)
                moireElements = [
                    SinOsc.ar(freq + (0.15 * (1 + t_pressure)), Rand(0, 2pi), 0.3),
                    SinOsc.ar(freq - (0.12 * (1 + t_pressure)), Rand(0, 2pi), 0.3),
                    VarSaw.ar(freq, 0, 0.5, 0.02 * (1 - t_fatigue))
                ].sum;

                // C. 振幅の動的制御
                movingAmp = SinOsc.kr(Rand(0.01, 0.02)).range(0.2, 0.6); // 初期状態の揺らぎ
                staticAmp = 0.4; // 純化後の完全な静止

                // 各レイヤーを純化エンベロープでクロスフェード・減衰
                (pureSine * SelectX.kr(purifyEnv, [movingAmp, staticAmp]))
                + (moireElements * (1 - purifyEnv));
            }).sum;

            sig = voices * mainEnv;

            // 空間処理 I: オールパスフィルタによる空間の拡張
            4.do {
                sig = AllpassC.ar(sig, 0.05, { Rand(0.02, 0.05) }!2, 2.0 + (purifyEnv * 3));
            };

            // 空間処理 II: リバーブ（後半にかけて高域の減衰がない最も透明な響きへシフト）
            rev = GVerb.ar(
                sig.sum,
                roomsize: 140,
                revtime: 8 + (purifyEnv * 7),
                damping: 0.4 * (1 - purifyEnv), // 純化完了でダンピングが完全に0（透明）になる
                spread: 60,
                drylevel: -6.dbamp,
                earlyreflevel: -24.dbamp,
                taillevel: -12.dbamp
            );

            rev = LeakDC.ar(rev);
            Limiter.ar(rev, 0.9);
        }.play;

        // --- Timeline Control ---
        totalDuration.wait;

        x.release(10);
        10.wait;

        s.stopRecording;
        "--- 録音終了：理想的な純化が完了しました ---".postln;
    }).play;
});