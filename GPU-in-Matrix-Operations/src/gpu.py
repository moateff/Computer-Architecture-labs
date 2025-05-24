"""
gpu.py

Benchmarking script to compare CPU (NumPy) vs GPU (CuPy) performance
on the matrix operation: A x B x C + A for square matrices of varying sizes.
"""

import time
import numpy as np
import cupy as cp
import matplotlib.pyplot as plt
from typing import Tuple, List


def generate_matrices(size: int, use_gpu: bool = False) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Generate three random square matrices of the specified size.
    """
    xp = cp if use_gpu else np
    A = xp.random.rand(size, size).astype(xp.float32)
    B = xp.random.rand(size, size).astype(xp.float32)
    C = xp.random.rand(size, size).astype(xp.float32)
    return A, B, C


def matrix_operation(
    A: np.ndarray | cp.ndarray,
    B: np.ndarray | cp.ndarray,
    C: np.ndarray | cp.ndarray,
    use_gpu: bool = False
) -> Tuple[np.ndarray, float]:
    """
    Perform the matrix computation: result = A × B × C + A.
    """
    xp = cp.get_array_module(A)
    start_time = time.perf_counter()

    result = xp.matmul(xp.matmul(A, B), C) + A

    if use_gpu:
        result = cp.asnumpy(result)

    elapsed_time = time.perf_counter() - start_time
    return result, elapsed_time


def benchmark(sizes: List[int]) -> Tuple[List[float], List[float]]:
    """
    Benchmark the matrix operation on CPU and GPU for different matrix sizes.
    """
    cpu_times = []
    gpu_times = []

    for size in sizes:
        print(f"Benchmarking size: {size}x{size}")

        # CPU
        A_cpu, B_cpu, C_cpu = generate_matrices(size, use_gpu=False)
        _, cpu_time = matrix_operation(A_cpu, B_cpu, C_cpu, use_gpu=False)
        cpu_times.append(cpu_time)

        # GPU
        A_gpu, B_gpu, C_gpu = generate_matrices(size, use_gpu=True)
        _, gpu_time = matrix_operation(A_gpu, B_gpu, C_gpu, use_gpu=True)
        gpu_times.append(gpu_time)

        print(f"  CPU time: {cpu_time:.4f} s | GPU time: {gpu_time:.4f} s\n")

    return cpu_times, gpu_times


def plot_results(sizes: List[int], cpu_times: List[float], gpu_times: List[float]) -> None:
    """
    Plot execution times of CPU vs GPU matrix operations and speedup.
    """
    speedups = [cpu / gpu for cpu, gpu in zip(cpu_times, gpu_times)]

    fig, ax1 = plt.subplots(figsize=(10, 6))

    # Plot execution times
    ax1.plot(sizes, cpu_times, 'o-', label='CPU (NumPy)', color='blue')
    ax1.plot(sizes, gpu_times, 'o-', label='GPU (CuPy)', color='green')
    ax1.set_xlabel("Matrix Size (N x N)")
    ax1.set_ylabel("Execution Time (seconds)", color='black')
    ax1.tick_params(axis='y', labelcolor='black')
    ax1.grid(True)

    # Add speedup on secondary y-axis
    ax2 = ax1.twinx()
    ax2.plot(sizes, speedups, 's--', label='Speedup (CPU/GPU)', color='red')
    ax2.set_ylabel("Speedup (×)", color='red')
    ax2.tick_params(axis='y', labelcolor='red')

    # Optional: Annotate speedup values
    for size, speedup in zip(sizes, speedups):
        ax2.annotate(f"{speedup:.1f}x", (size, speedup), textcoords="offset points", xytext=(0, 5),
                     ha='center', color='red', fontsize=8)

    # Combine legends
    lines, labels = ax1.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax1.legend(lines + lines2, labels + labels2, loc='upper left')

    plt.title("CPU vs GPU Execution Time and Speedup")
    plt.tight_layout()
    plt.show()


def main() -> None:
    """
    Entry point: runs the benchmark and displays the results.
    """
    sizes = [128, 256, 512, 1024, 2048, 4096]
    cpu_times, gpu_times = benchmark(sizes)
    plot_results(sizes, cpu_times, gpu_times)


if __name__ == "__main__":
    main()
