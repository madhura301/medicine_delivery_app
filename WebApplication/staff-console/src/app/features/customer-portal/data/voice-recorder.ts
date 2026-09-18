/**
 * Records a voice note as a WAV file.
 *
 * `MediaRecorder` would be simpler, but Chrome and Edge only record WebM, which the API rejects —
 * it accepts .mp3/.wav/.m4a/.aac/.ogg and checks each file's magic bytes rather than trusting the
 * extension. So this captures raw audio through Web Audio and writes a 16 kHz mono 16-bit WAV,
 * which every browser can produce and the server's RIFF/WAVE signature check accepts. At that rate
 * the API's 10 MB cap allows about five minutes of speech.
 */

const TARGET_SAMPLE_RATE = 16_000;
export const MAX_RECORDING_SECONDS = 300;

export class VoiceRecorder {
  private context: AudioContext | null = null;
  private stream: MediaStream | null = null;
  private processor: ScriptProcessorNode | null = null;
  private source: MediaStreamAudioSourceNode | null = null;
  private chunks: Float32Array[] = [];
  private inputRate = 44_100;

  static isSupported(): boolean {
    return !!navigator.mediaDevices?.getUserMedia && typeof AudioContext !== 'undefined';
  }

  async start(): Promise<void> {
    this.chunks = [];
    this.stream = await navigator.mediaDevices.getUserMedia({
      audio: { echoCancellation: true, noiseSuppression: true },
    });
    this.context = new AudioContext();
    this.inputRate = this.context.sampleRate;
    this.source = this.context.createMediaStreamSource(this.stream);
    // ScriptProcessorNode is deprecated but supported everywhere, and a voice note does not need
    // AudioWorklet's lower latency.
    this.processor = this.context.createScriptProcessor(4096, 1, 1);
    this.processor.onaudioprocess = (event) => {
      this.chunks.push(new Float32Array(event.inputBuffer.getChannelData(0)));
    };
    this.source.connect(this.processor);
    this.processor.connect(this.context.destination);
  }

  /** Stops recording and returns the note as a WAV file. */
  async stop(): Promise<File> {
    this.processor?.disconnect();
    this.source?.disconnect();
    this.stream?.getTracks().forEach((track) => track.stop());
    await this.context?.close();

    const samples = downsample(merge(this.chunks), this.inputRate, TARGET_SAMPLE_RATE);
    const blob = encodeWav(samples, TARGET_SAMPLE_RATE);
    this.reset();

    const stamp = new Date().toISOString().replace(/[:.]/g, '-');
    return new File([blob], `voice-order-${stamp}.wav`, { type: 'audio/wav' });
  }

  cancel(): void {
    this.processor?.disconnect();
    this.source?.disconnect();
    this.stream?.getTracks().forEach((track) => track.stop());
    void this.context?.close();
    this.reset();
  }

  private reset(): void {
    this.context = null;
    this.stream = null;
    this.processor = null;
    this.source = null;
    this.chunks = [];
  }
}

function merge(chunks: Float32Array[]): Float32Array {
  const length = chunks.reduce((sum, chunk) => sum + chunk.length, 0);
  const result = new Float32Array(length);
  let offset = 0;
  for (const chunk of chunks) {
    result.set(chunk, offset);
    offset += chunk.length;
  }
  return result;
}

/** Averaging decimation — adequate for speech, and keeps the file a quarter of the size. */
function downsample(samples: Float32Array, fromRate: number, toRate: number): Float32Array {
  if (toRate >= fromRate) {
    return samples;
  }
  const ratio = fromRate / toRate;
  const length = Math.floor(samples.length / ratio);
  const result = new Float32Array(length);
  for (let i = 0; i < length; i++) {
    const start = Math.floor(i * ratio);
    const end = Math.min(Math.floor((i + 1) * ratio), samples.length);
    let sum = 0;
    for (let j = start; j < end; j++) {
      sum += samples[j];
    }
    result[i] = sum / Math.max(1, end - start);
  }
  return result;
}

function encodeWav(samples: Float32Array, sampleRate: number): Blob {
  const bytesPerSample = 2;
  const buffer = new ArrayBuffer(44 + samples.length * bytesPerSample);
  const view = new DataView(buffer);
  const write = (offset: number, text: string) => {
    for (let i = 0; i < text.length; i++) {
      view.setUint8(offset + i, text.charCodeAt(i));
    }
  };

  write(0, 'RIFF');
  view.setUint32(4, 36 + samples.length * bytesPerSample, true);
  write(8, 'WAVE'); // the server's signature check reads these four bytes at offset 8
  write(12, 'fmt ');
  view.setUint32(16, 16, true);
  view.setUint16(20, 1, true); // PCM
  view.setUint16(22, 1, true); // mono
  view.setUint32(24, sampleRate, true);
  view.setUint32(28, sampleRate * bytesPerSample, true);
  view.setUint16(32, bytesPerSample, true);
  view.setUint16(34, 16, true);
  write(36, 'data');
  view.setUint32(40, samples.length * bytesPerSample, true);

  let offset = 44;
  for (const sample of samples) {
    const clamped = Math.max(-1, Math.min(1, sample));
    view.setInt16(offset, clamped < 0 ? clamped * 0x8000 : clamped * 0x7fff, true);
    offset += bytesPerSample;
  }
  return new Blob([buffer], { type: 'audio/wav' });
}
