import sys

import numpy as np
from scipy.io import wavfile
from scipy import signal as sg



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

def quantize(signal, bits):
    steps = 2 ** bits
    step_size = (signal.max() - signal.min()) / steps
    for i in range(len(signal)):
        quantized = np.round(signal[i] / step_size) * step_size
        signal[i] = quantized
    return np.clip(signal, signal.min(), signal.max())


def adaptive_quantize(signal, bits):
    steps = 2 ** bits
    max_amp = np.max(np.abs(signal))

    quantized = np.zeros_like(signal)
    for i in range(len(signal)):
        local_max = np.max(np.abs(signal[max(0, i - 1000):min(len(signal), i + 1000)]))
        print(local_max)
        step_size = (local_max * 2) / steps
        quantized[i] = np.round(signal[i] / step_size) * step_size

    return quantized


def nonlinear_quantize(signal, bits):
    steps = 2 ** bits
    abs_max = np.max(np.abs(signal))

    # Apply non-linear transformation (e.g., cube root)
    transformed = np.sign(signal) * np.power(np.abs(signal) / abs_max, 1 / 3)

    # Quantize the transformed signal
    step_size = 2 / steps
    quantized = np.round(transformed / step_size) * step_size

    # Inverse transform
    return np.sign(quantized) * np.power(np.abs(quantized), 3) * abs_max


import numpy as np


def smooth_and_quantize(signal, bits, window_length=5):
    # Apply smoothing
    smoothed = np.convolve(signal, np.ones(window_length) / window_length, mode='same')

    # Quantize
    steps = 2 ** bits
    step_size = (smoothed.max() - smoothed.min()) / steps
    quantized = np.round(smoothed / step_size) * step_size

    return quantized


def advanced_noise_shape_and_quantize(signal, bits, shaping_coefficient=0.5, filter_cutoff=0.5):
    steps = 2 ** bits
    step_size = (signal.max() - signal.min()) / steps

    shaped = np.zeros_like(signal)
    error = np.zeros_like(signal)

    # Noise shaping and dithering
    for i in range(len(signal)):
        dither = np.random.uniform(-step_size / 8, step_size / 8)
        shaped[i] = signal[i] + dither - error[i]
        quantized = np.round(shaped[i] / step_size) * step_size
        error[i] = quantized - signal[i]
        if i < len(signal) - 1:
            error[i + 1] = error[i] * shaping_coefficient

    # Design low-pass filter
    filter_order = 4
    b, a = sg.butter(filter_order, filter_cutoff, 'low')

    # Apply low-pass filter
    filtered = sg.filtfilt(b, a, shaped)

    # Final quantization
    quantized = np.round(filtered / step_size) * step_size
    return np.clip(quantized, signal.min(), signal.max())

# Read the WAV file
original_sr, data = wavfile.read(sys.argv[1])
data = data.astype(float)
data = data / np.max(np.abs(data))

# Define target sample rate
target_sr = 5000  # 6 kHz

# Resample the audio
#resampled_data = resample_audio(data, original_sr, target_sr)
resampled_data = data

# Apply noise shaping and quantization
quantized = noise_shape_and_quantize(resampled_data, 4)
# quantized = quantize(resampled_data, 4)
# quantized = adaptive_quantize(resampled_data, 4)
# quantized = nonlinear_quantize(resampled_data, 4)
# quantized = smooth_and_quantize(resampled_data, 4)
# quantized = advanced_noise_shape_and_quantize(resampled_data, 4, shaping_coefficient=0.5, filter_cutoff=0.5)
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
    # else:
    #     byte = scaled[i] << 4
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
print("First and last 10 bytes in hex:")
print(" ".join(f"{b:02X}" for b in packed[:10]))
print(" ".join(f"{b:02X}" for b in packed[-10:]))

# Save the resampled audio as a WAV file for verification
# Correctly scale back to 16-bit audio range
wav_output = (scaled.astype(float) - 7.5) / 7.5  # Center around 0
wav_output = (wav_output * 32767).astype(np.int16)  # Scale to 16-bit range
#wavfile.write('resampled_output.wav', target_sr, wav_output)
