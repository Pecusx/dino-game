import sys

import numpy as np
from scipy.io import wavfile
from scipy import signal



def resample_audio(audio, original_sr, target_sr):
    number_of_samples = round(len(audio) * float(target_sr) / original_sr)
    return signal.resample(audio, number_of_samples)


def noise_shape_and_quantize(signal, bits):
    steps = 2 ** bits
    step_size = (signal.max() - signal.min()) / steps

    shaped = np.zeros_like(signal)
    error = np.zeros_like(signal)

    for i in range(len(signal)):
        shaped[i] = signal[i] - error[i]
        quantized = np.round(shaped[i] / step_size) * step_size
        error[i] = quantized - signal[i]
        if i < len(signal) - 1:
            error[i + 1] = error[i] * 0.5  # Simple first-order noise shaping

        shaped[i] = quantized

    return np.clip(shaped, signal.min(), signal.max())


# Read the WAV file
original_sr, data = wavfile.read(sys.argv[1])
data = data.astype(float)
data = data / np.max(np.abs(data))

# Define target sample rate
target_sr = 5000  # 6 kHz

# Resample the audio
resampled_data = resample_audio(data, original_sr, target_sr)

# Apply noise shaping and quantization
quantized = noise_shape_and_quantize(resampled_data, 4)

# Scale to 0-15 range and round to integers
scaled = np.round((quantized - quantized.min()) / (quantized.max() - quantized.min()) * 15).astype(int)
scaled = np.clip(scaled, 0, 15)

print("Min value:", scaled.min())
print("Max value:", scaled.max())
print("Unique values:", np.unique(scaled))

# Pack 4-bit values into bytes
packed = []
for i in range(0, len(scaled), 2):
    if i + 1 < len(scaled):
        byte = (scaled[i] << 4) | scaled[i + 1]
    else:
        byte = scaled[i] << 4
    packed.append(byte)

# Write packed data to binary file
with open(sys.argv[1]+'.bin', 'wb') as f:
    f.write(bytes(packed))

print(f"Packed 4-bit data written to output.bin")
print(f"Original sample rate: {original_sr} Hz")
print(f"New sample rate: {target_sr} Hz")
print(f"Number of samples: {len(scaled)}")
print(f"Duration: {len(scaled) / target_sr:.2f} seconds")

# Print first few bytes in hex
print("First 10 bytes in hex:")
print(" ".join(f"{b:02X}" for b in packed[:10]))

# Save the resampled audio as a WAV file for verification
# Correctly scale back to 16-bit audio range
wav_output = (scaled.astype(float) - 7.5) / 7.5  # Center around 0
wav_output = (wav_output * 32767).astype(np.int16)  # Scale to 16-bit range
#wavfile.write('resampled_output.wav', target_sr, wav_output)
